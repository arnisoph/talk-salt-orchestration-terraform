resource "digitalocean_droplet" "saltmaster" {
  count = 1
  image = "centos-7-0-x64"
  name = "saltmaster${count.index}"
  region = "ams3"
  size = "2gb"
  private_networking = true
  ipv6 = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]

  provisioner "local-exec" {
    command = "sleep 120"
  }

  connection {
      user = "root"
      type = "ssh"
      key_file = "${var.pvt_key}"
      timeout = "5m"
  }

  provisioner "file" {
    source = "provision.sh"
    destination = "/tmp/terraform-provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/terraform-provision.sh && /tmp/terraform-provision.sh 127.0.0.1"
    ]
  }
}
