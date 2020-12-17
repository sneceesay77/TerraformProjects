# Configure Google Provider
provider "google" {
  project = "cloud-brokerage"
  region  = "europe-west-2"
  zone = "europe-west2-a"
}

#test is name scope to terraform, started with n1-standard-1 then to n1-standard-2
#See here for https://cloud.google.com/compute/all-pricing
resource "google_compute_instance" "abc-server"{
    name = "web-server"
    #machine_type = "n1-standard-1"
    #machine_type = "n1-standard-2"
    #machine_type = "n1-standard-4"
    machine_type = "custom-6-5632-ext"
 
    boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
    #source = "${google_compute_disk.new-disk.name}"
   }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }

  metadata = {
    ssh-keys = "sc306:${file("../id_rsa.pub")}"
  }

   metadata_startup_script = "${file("install")}"
   
   allow_stopping_for_update = true

}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

output "ip" {
 value = google_compute_instance.abc-server.network_interface.0.access_config.0.nat_ip
}


resource "google_compute_firewall" "default" {
 name    = "cloud-brokerage-firewall"
 network = "default"


 allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }
}

#Resize from the original snapshot

#Step 1: Create a snapshot
#resource "google_compute_snapshot" "abc-server"{
#  name = "abc-server-snapshot"
#  source_disk = "${google_compute_instance.abc-server.name}"
#  zone = "europe-west2-a"
#}

#resource "google_compute_disk" "new-disk" {
#  name = "new-disk"
  #type = "pd-ssd"
#  zone = "europe-west2-a"
#  size = 150
  #snapshot = "${google_compute_snapshot.abc-server.name}"
#}
