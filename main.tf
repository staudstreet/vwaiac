variable "group1_size" {
  default = "2"
}

variable "group2_size" {
  default = "2"
}

variable "group1_region" {
  default = "europe-west2"
}

variable "group2_region" {
  default = "europe-west3"
}

variable "network_name" {
  default = "tf-lb-http-basic"
}

provider "google" {
  region	= "${var.group1_region}"
  credentials 	= "${file("terraform.json")}"
  project     	= "vwaiac"
}

resource "google_compute_network" "default" {
  name                    = "${var.network_name}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "group1" {
  name                     = "${var.network_name}"
  ip_cidr_range            = "10.126.0.0/20"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "${var.group1_region}"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "group2" {
  name                     = "${var.network_name}"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "${var.group2_region}"
  private_ip_google_access = true
}

module "gce-lb-http" {
  source            = "GoogleCloudPlatform/lb-http/google"
  name              = "${var.network_name}"
  target_tags       = ["${module.mig1.target_tags}", "${module.mig2.target_tags}"]
  firewall_networks = ["${google_compute_network.default.name}"]

  backends = {
    "0" = [
      {
        group = "${module.mig1.region_instance_group}"
      },
      {
        group = "${module.mig2.region_instance_group}"
      },
    ]
  }

  backend_params = [
    // health check path, port name, port number, timeout seconds.
    "/,http,80,10",
  ]
}

output "load-balancer-ip" {
  value = "${module.gce-lb-http.external_ip}"
}
