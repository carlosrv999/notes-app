resource "google_compute_firewall" "default" {
  name    = "ssh"
  network = var.network_id

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    var.home_ip_address
  ]

  target_service_accounts = [
    var.service_account_email
  ]

}

resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"]
    ]
  }

  boot_disk { #tfsec:ignore:google-compute-vm-disk-encryption-customer-key
    auto_delete = true
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnetwork_id
    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  metadata = {
    block-project-ssh-keys = true
  }

  shielded_instance_config {
    enable_vtpm = true
  }
}
