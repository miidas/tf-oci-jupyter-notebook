output "compute_id" {
  value = oci_core_instance.generated_oci_core_instance.id
}

output "compute_public_ip" {
  value = var.use_reserved_public_ip ? data.oci_core_public_ip.generated_oci_core_public_ip.ip_address : oci_core_instance.generated_oci_core_instance.public_ip
}

output "compute_private_ip" {
  value = oci_core_instance.generated_oci_core_instance.private_ip
}