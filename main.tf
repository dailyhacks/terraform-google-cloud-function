# Proveedor
provider "google" {
  version = "3.5.0"

  # Archivo JSON descargado desde la consola
  credentials = file("<NAME>.json") // highlight-line

  # ID del proyecto en GCP
  project = "<PROJECT_ID>" // highlight-line
  region  = "us-central1"
  zone    = "us-central1-c"
}

# Bucket para almacenar el código fuente
resource "google_storage_bucket" "source_bucket" {
  name     = "hello-world-source"
  location = "us-central1"
}

# Almacenar source.zip al bucket
resource "google_storage_bucket_object" "archive" {
  name   = "source.zip"
  bucket = google_storage_bucket.source_bucket.name
  source = "./source.zip"
}

# Cloud Function
resource "google_cloudfunctions_function" "function" {
  name        = "function-test"
  description = "Hola Mundo"
  runtime     = "python37"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.source_bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "handler"
}

# Permiso para invocar la función
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}