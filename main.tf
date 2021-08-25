resource "oci_core_instance" "generated_oci_core_instance" {
  agent_config {
    is_management_disabled = "false"
    is_monitoring_disabled = "false"
    plugins_config {
      desired_state = "DISABLED"
      name          = "Vulnerability Scanning"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Management Agent"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Custom Logs Monitoring"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Bastion"
    }
  }
  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  create_vnic_details {
    assign_private_dns_record = "true"
    assign_public_ip          = var.use_reserved_public_ip ? "false" : "true"
    private_ip                = var.vnic_private_ip
    subnet_id                 = oci_core_subnet.generated_oci_core_subnet.id
  }
  instance_options {
    are_legacy_imds_endpoints_disabled = "false"
  }
  is_pv_encryption_in_transit_enabled = "true"
  metadata = {
    "user_data"           = filebase64(var.cloudinit_config_path)
    "ssh_authorized_keys" = file(var.ssh_authorized_keys_path)
  }
  shape = var.compute_shape
  source_details {
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
    source_id               = var.compute_source_type == "image" ? var.boot_image_source_id : var.boot_volume_source_id
    source_type             = var.compute_source_type
  }
  preserve_boot_volume = var.compute_preserve_boot_volume
}

resource "oci_core_vcn" "generated_oci_core_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_id
}

resource "oci_core_subnet" "generated_oci_core_subnet" {
  cidr_block     = "10.0.0.0/24"
  compartment_id = var.compartment_id
  route_table_id = oci_core_vcn.generated_oci_core_vcn.default_route_table_id
  vcn_id         = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_internet_gateway" "generated_oci_core_internet_gateway" {
  compartment_id = var.compartment_id
  enabled        = "true"
  vcn_id         = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_default_route_table" "generated_oci_core_default_route_table" {
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.generated_oci_core_internet_gateway.id
  }
  manage_default_resource_id = oci_core_vcn.generated_oci_core_vcn.default_route_table_id
}

data "oci_core_private_ips" "generated_oci_core_private_ips" {
  ip_address = oci_core_instance.generated_oci_core_instance.private_ip
  subnet_id  = oci_core_subnet.generated_oci_core_subnet.id
}

data "oci_core_public_ip" "generated_oci_core_public_ip" {
  ip_address = var.vnic_reserved_public_ip
}

resource "null_resource" "update_public_ip" {
  count = var.use_reserved_public_ip ? 1 : 0
  provisioner "local-exec" {
    command = "oci network public-ip update --public-ip-id $RESERVED_PUBLIC_IP_ID --private-ip-id $PRIVATE_IP_ID --auth security_token > /dev/null"
    environment = {
      PRIVATE_IP_ID         = data.oci_core_private_ips.generated_oci_core_private_ips.private_ips[0]["id"]
      RESERVED_PUBLIC_IP_ID = data.oci_core_public_ip.generated_oci_core_public_ip.id
    }
  }
}

resource "null_resource" "cloudinit_wait" {
  depends_on = [null_resource.update_public_ip]
  count      = var.compute_source_type == "image" ? 1 : 0
  provisioner "remote-exec" {
    connection {
      agent       = "false"
      timeout     = "10m"
      host        = var.use_reserved_public_ip ? data.oci_core_public_ip.generated_oci_core_public_ip.ip_address : oci_core_instance.generated_oci_core_instance.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }
    inline = [
      "cloud-init status --wait > /dev/null"
    ]
  }
}

resource "null_resource" "generate_bootvolume_tfvars" {
  depends_on = [oci_core_instance.generated_oci_core_instance]
  count      = var.compute_preserve_boot_volume ? var.compute_source_type == "image" ? 1 : 0 : 0
  provisioner "local-exec" {
    command = <<-EOT
		echo "compute_source_type          = \"bootVolume\"" >> $TFVARS_FILE
		echo "compute_preserve_boot_volume = \"true\"" >> $TFVARS_FILE
		echo "boot_volume_source_id        = \"${oci_core_instance.generated_oci_core_instance.boot_volume_id}\"" >> $TFVARS_FILE
    EOT
    environment = {
      TFVARS_FILE = "${oci_core_instance.generated_oci_core_instance.display_name}.tfvars"
    }
  }
}