provider "vsphere" {
   user           = "Administrator@vsphere.local"
   password       = "Your-VCENTER_PASSWORD" # You vcenter password
   vsphere_server = "MY_VCENTER" # You vcenter ip or FQDN
   allow_unverified_ssl = "true"
 }

data "vsphere_datacenter" "dc" {
  name = "datacenter_NAME" # You datacenter Name
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1" #You datastore
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
} 

data "vsphere_datastore" "sas-datastore" {
  name          = "sas-datastore" #You datastore
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "ssd-datastore" {
  name          = "ssd-datastore" #You datastore
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "clusters" #You resources-pool
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool-1" {
   name          = "clusters-1" #You resources-pool
   datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "vlan-default" # You network selected
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "clusters/Centos7" # Template Name for Centos 7
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "haproxy1" {
  name             = "haproxy1 - 172.16.250.151" # HAPROXY1 NAME
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "clusters"
  num_cpus = 1
  memory   = 512
  guest_id = "centos64Guest"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"


  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

 # In my case I used 2 disk in the tempalte but you only need your template disk. 

  disk {
    label            = "disk1"
    unit_number      = 1
    size             = "${data.vsphere_virtual_machine.template.disks.1.size}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.1.thin_provisioned}"
  }

  disk {
    label             = "disk0"
     unit_number      =  0
     size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
     eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
     thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
   }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "haproxy1" # HAPROXY1 HOSTNAME
        domain    = "itshell.local"
      }

      network_interface {
        ipv4_address = "172.16.250.151"  # HAPROXY1 IP
        ipv4_netmask = 24
      }

      ipv4_gateway = "172.16.250.1"
      dns_server_list = ["172.16.250.2"]
    }
  }
}

resource "vsphere_virtual_machine" "haproxy2" {
  name             = "haproxy2 - 172.16.250.152" # HAPROXY2 NAME
  resource_pool_id = "${data.vsphere_resource_pool.pool-1.id}"
  datastore_id     = "${data.vsphere_datastore.sas-datastore.id}"
  folder           = "clusters"
  num_cpus = 1
  memory   = 512
  guest_id = "centos64Guest"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"


  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

 # In my case I used 2 disk in the tempalte but you only need your template disk.

  disk {
    label            = "disk1"
    unit_number      = 1
    size             = "${data.vsphere_virtual_machine.template.disks.1.size}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.1.thin_provisioned}"
  }

  disk {
    label             = "disk0"
     unit_number      =  0
     size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
     eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
     thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
   }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "haproxy2" # HAPROXY2 HOSTNAME
        domain    = "itshell.local"
      }

      network_interface {
        ipv4_address = "172.16.250.152" # HAPROXY2 IP
        ipv4_netmask = 24
      }

      ipv4_gateway = "172.16.250.1"
      dns_server_list = ["172.16.250.2"]
    }
  }
}
