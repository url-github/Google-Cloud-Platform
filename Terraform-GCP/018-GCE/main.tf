resource "google_compute_instance" "vm-from-tf" {
  name = "vm-from-tf"
  zone = "asia-southeast1-a"
  machine_type = "n1-standard-2"

  allow_stopping_for_update = true

  network_interface {
    network = "custom-vpc-tf"
    subnetwork = "sub-sg"
  }

  boot_disk {
    initialize_params {
      image = "debian-9-stretch-v20210916"
      size = 35

    }
    auto_delete = false
  }

  labels = {
    "env" = "tfleaning"
  }


  scheduling {
    preemptible = false
    automatic_restart = false
  }

  service_account {
    email = "terraform-gcp@terraform-gcp-326702.iam.gserviceaccount.com"
    scopes = [ "cloud-platform" ]
  }

  lifecycle {
    ignore_changes = [
      attached_disk
    ]
  }

}

resource "google_compute_disk" "disk-1" {
  name = "disk-1"
  size = 15
  zone = "asia-southeast1-a"
  type = "pd-ssd"
}

resource "google_compute_attached_disk" "adisk" {
  disk = google_compute_disk.disk-1.id
  instance = google_compute_instance.vm-from-tf.id
}

# kod Terraform tworzy następujące zasoby w Google Cloud Platform (GCP):
# 	1.	Instancja VM:
# 	•	Zasób google_compute_instance definiuje maszynę wirtualną (VM) z określonymi parametrami (typ maszyny, dysk rozruchowy, sieć itp.).
# 	2.	Dodatkowy dysk:
# 	•	Zasób google_compute_disk definiuje dodatkowy dysk SSD o pojemności 15 GB.
# 	3.	Przypisanie dysku do instancji:
# 	•	Zasób google_compute_attached_disk dołącza dodatkowy dysk do maszyny wirtualnej.