output "instance_public_ip" {
  value       = oci_core_instance.web_server.public_ip
  description = "The public IP address of the deployed compute instance."
}

