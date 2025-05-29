output "filename" {
  value = data.local_file.compute_asset.filename
}

output "full_path" {
  value = abspath(data.local_file.compute_asset.filename)
}
