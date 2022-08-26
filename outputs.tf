output "sql_private_ip_address" {
  value = module.database.sql_private_ip_address
}

output "sql_public_ip_address" {
  value = module.database.sql_public_ip_address
}
/*
output "compute_instance_public_ip" {
  value = module.compute.public_ip_address
}*/
