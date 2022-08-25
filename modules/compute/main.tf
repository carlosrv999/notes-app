resource "google_service_account" "default" {
  account_id   = "notesapp-account"
  display_name = "NotesApp Service Account"
}

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
    google_service_account.default.email
  ]

}

resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk { #tfsec:ignore:google-compute-vm-disk-encryption-customer-key
    auto_delete = true
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = var.network_id
    subnetwork = var.subnetwork_id
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    block-project-ssh-keys = true
  }

  shielded_instance_config {
    enable_vtpm = true
  }
}
