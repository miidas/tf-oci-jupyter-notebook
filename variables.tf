variable "availability_domain" {
  type    = string
  default = ""
}

variable "compartment_id" {
  type    = string
  default = ""
}

# Oracle Cloud Infrastructure Documentation / Compute Shapes
# https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm
variable "compute_shape" {
  type    = string
  default = "VM.Standard.E2.4"
}

variable "compute_source_type" {
  type    = string
  default = "image" # image or bootVolume
}

variable "compute_preserve_boot_volume" {
  type    = string
  default = "false"
}

variable "use_reserved_public_ip" {
  type    = string
  default = "false"
}

variable "vnic_reserved_public_ip" {
  type    = string
  default = "0.0.0.0" # Input 0.0.0.0 or reserved public ip
}

variable "vnic_private_ip" {
  type    = string
  default = "10.0.0.2"
}

# Oracle Cloud Infrastructure Documentation / Images
# https://docs.oracle.com/en-us/iaas/images/
variable "boot_image_source_id" {
  type    = string
  default = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaaymes4ncljbztzxnf5bchyc7ag4oumbh5nwxt2wrbxfyycdngc6yq"
}

variable "boot_volume_source_id" {
  type    = string
  default = ""
}

variable "boot_volume_size_in_gbs" {
  type    = string
  default = "64"
}

variable "cloudinit_config_path" {
  type    = string
  default = "cloud-init.yml"
}

variable "ssh_authorized_keys_path" {
  type    = string
  default = "~/path/to/file"
}

variable "ssh_private_key_path" {
  type    = string
  default = "~/path/to/file"
}
