variable "tenancy_ocid" {
  type        = string
  description = "The OCID of your OCI tenancy"
}

variable "user_ocid" {
  type        = string
  description = "The OCID of the OCI user"
}

variable "fingerprint" {
  type        = string
  description = "The fingerprint of your OCI API signing key"
}

variable "private_key_path" {
  type        = string
  description = "Local path to your OCI private API key file"
}

variable "region" {
  type    = string
  default = "ap-mumbai-1"
}

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where resources will be created"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Absolute path to the public SSH key file"
}

variable "instance_shape" {
  type    = string
  default = "VM.Standard.E2.1.Micro"
}
