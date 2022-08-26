module "network" {
  source = "./modules/network"

  network_name = "vpc-notesapp"
  public_subnets = [
    "10.100.0.0/21",
  ]
  private_subnets = [
    "10.100.8.0/21",
  ]
  public_subnet_suffix  = "public-project-notesapp"
  private_subnet_suffix = "private-project-notesapp"
  region                = var.region

}

module "database" {
  source = "./modules/database"

  network_id               = module.network.network_id
  cidr_block               = "10.100.32.0"
  private_ip_address_name  = "private-sql-network"
  cidr_block_prefix_length = 20
  region                   = var.region
  database_version         = "POSTGRES_14"
  home_ip_address          = "38.25.18.114"
  instance_name            = "notesapp-database-7"
  instance_specs           = var.db_instance_specs

}

module "compute" {
  source = "./modules/compute"

  machine_type          = var.machine_type
  zone                  = "us-central1-c"
  home_ip_address       = "38.25.18.114/32"
  network_id            = module.network.network_id
  subnetwork_id         = module.network.public_subnets_names[0]
  instance_name         = "vm-web-notesapp"
  service_account_email = google_service_account.default.email

}

module "compute-temporal" {
  source = "./modules/compute"

  machine_type          = var.machine_type
  zone                  = "us-central1-c"
  home_ip_address       = "38.25.18.114/32"
  network_id            = module.network.network_id
  subnetwork_id         = module.network.public_subnets_names[0]
  instance_name         = "vm-web-notesapp-2"
  service_account_email = google_service_account.default.email

}

resource "google_service_account" "default" {
  account_id   = "notesapp-account"
  display_name = "NotesApp Service Account"
}

resource "google_compute_firewall" "default" {
  name    = "nodejs"
  network = module.network.network_id

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = [
    "0.0.0.0/0",
  ]

  target_service_accounts = [
    google_service_account.default.email
  ]

}

resource "google_sql_user" "default" {
  name     = "administrator"
  instance = module.database.instance_name
  password = "DcbTrFuHbVq2We6G3#dB"
}

resource "google_sql_database" "default" {
  charset   = "UTF8"
  collation = "en_US.UTF8"
  instance  = module.database.instance_name
  name      = "notesapp"
}
