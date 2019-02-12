data "template_file" "group-startup-script" {
  template = "${file("setup.sh")}"

  vars {
    PROXY_PATH = ""
  }
}

module "mig1" {
  source            = "GoogleCloudPlatform/managed-instance-group/google"
  version           = "1.1.14"
  zonal             = false
  region            = "${var.group1_region}"
  name              = "${var.network_name}-group1"
  size              = "${var.group1_size}"
  target_tags       = ["${var.network_name}-group1"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group-startup-script.rendered}"
  network           = "${google_compute_subnetwork.group1.name}"
  subnetwork        = "${google_compute_subnetwork.group1.name}"
}

module "mig2" {
  source            = "GoogleCloudPlatform/managed-instance-group/google"
  version           = "1.1.14"
  zonal             = false
  region            = "${var.group2_region}"
  name              = "${var.network_name}-group2"
  size              = "${var.group2_size}"
  target_tags       = ["${var.network_name}-group2"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group-startup-script.rendered}"
  network           = "${google_compute_subnetwork.group2.name}"
  subnetwork        = "${google_compute_subnetwork.group2.name}"
}
