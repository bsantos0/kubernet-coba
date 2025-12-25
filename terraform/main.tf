#1. mengumpulkan data infrastruktur vSphere
data "vsphere_datacenter" "dc" {
  name = "ha-datacenter"
}
data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_host" "host" {
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_resource_pool" "pool" {
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_virtual_machine" "template-vm" {
  name          = var.vm_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

#2. membuat VM Kubernets Master baru dari template
resource "vsphere_virtual_machine" "k8s-master" {
  name             = "k8s-master-01"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 2048
  guest_id = data.vsphere_virtual_machine.template-vm.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template-vm.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = 40
    eagerly_scrub    = false
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template-vm.id
    }
}

#3. Membuat VM Kubernets Worker baru dari template
resource "vsphere_virtual_machine" "k8s-worker" {
  count            = 2
  name             = "k8s-worker-0${count.index + 1}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 4
  memory   = 8192
  guest_id = data.vsphere_virtual_machine.template-vm.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template-vm.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = 60
    eagerly_scrub    = false
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template-vm.id
    }
}
