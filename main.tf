module "network" {
  source = "./modules/network"

  network_name = "vpc-carlos"
  public_subnets = [
    "10.100.0.0/21",
    "10.100.8.0/21",
  ]
  public_subnet_suffix = "public-project-carlos"
  region               = var.region

}
