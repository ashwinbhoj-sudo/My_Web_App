terraform {
  required_version = ">= 1.3.0"

  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.instance_shape

  sort_by    = "TIMECREATED"
  sort_order = "DESC"
}

resource "oci_core_vcn" "web_vcn" {
  compartment_id = var.compartment_id
  display_name   = "web-app-vcn"
  dns_label      = "webvcn"
  cidr_block     = "10.0.0.0/16"
}

resource "oci_core_internet_gateway" "web_ig" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.web_vcn.id
  display_name   = "web-app-internet-gateway"
  enabled        = true
}

resource "oci_core_route_table" "web_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.web_vcn.id
  display_name   = "web-app-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.web_ig.id
  }
}

resource "oci_core_security_list" "web_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.web_vcn.id
  display_name   = "web-app-security-list"

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  # SSH — change source to your public IP/CIDR when possible.
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 22
      max = 22
    }
  }

  # FastAPI
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 8000
      max = 8000
    }
  }
}

resource "oci_core_subnet" "web_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.web_vcn.id
  display_name               = "web-app-public-subnet"
  dns_label                  = "websubnet"
  cidr_block                 = "10.0.1.0/24"
  route_table_id             = oci_core_route_table.web_rt.id
  security_list_ids          = [oci_core_security_list.web_sl.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_instance" "web_server" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "fastapi-web-server"
  shape               = var.instance_shape

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.oracle_linux.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.web_subnet.id
    display_name     = "primary-vnic"
    hostname_label   = "fastapiweb"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = trimspace(file(var.ssh_public_key_path))
  }
}
