terraform {
  required_providers {
    vsphere = {
        source = "hashicorp/vsphere"
        version = "2.6.1"
    }
  }
}

provider "vsphere" {
  user = var.esxi_host_user
  password = var.esxi_host_password
  vsphere_server = var.esxi_host_ip
  allow_unverified_ssl = true
}