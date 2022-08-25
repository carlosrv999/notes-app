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
  instance_name            = "notesapp-database-2"
  instance_specs           = var.db_instance_specs

}

module "compute" {
  source = "./modules/compute"

  machine_type    = var.machine_type
  zone            = "us-central1-c"
  home_ip_address = "38.25.18.114/32"
  network_id      = module.network.network_id
  subnetwork_id   = module.network.public_subnets_names[0]
  instance_name   = "vm-web-notesapp"

}
