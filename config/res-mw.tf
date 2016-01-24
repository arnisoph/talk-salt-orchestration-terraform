resource "digitalocean_droplet" "mw" {
  count = 10
  image = "centos-7-0-x64"
  name = "mw${count.index}"
  region = "ams3"
  size = "1gb"
  private_networking = true
  ipv6 = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]

  depends_on = [
    "digitalocean_droplet.saltmaster",
    "digitalocean_droplet.db"
  ]

  provisioner "local-exec" {
    command = "sleep 60"
  }

  connection {
      user = "root"
      type = "ssh"
      key_file = "${var.pvt_key}"
      timeout = "5m"
      agent = false
  }

  provisioner "file" {
    source = "provision.sh"
    destination = "/tmp/terraform-provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "source /tmp/terraform-provision.sh ${digitalocean_droplet.saltmaster.ipv4_address_private}"
    ]
  }
}
