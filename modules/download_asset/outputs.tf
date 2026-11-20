output "filename" {
  description = "Path to the downloaded package, relative to the root module. The file exists after apply"
  value       = terraform_data.download.output
}

output "version" {
  description = "Release tag of the downloaded package, for example v0.4.2"
  value       = local.selected_tag
}
