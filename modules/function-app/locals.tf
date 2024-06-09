locals {
  randint  = random_integer.randint.result
  location = replace(lower(var.location), " ", "")
  # archive_md5 = filemd5(data.archive_file.functionapp.output_path)
}
