/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


/*****************************************
  Activate Services in Jenkins Project
 *****************************************/
module "enables-google-apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"

  project_id = var.project_id

  activate_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "containerregistry.googleapis.com",
    "container.googleapis.com",
    "storage-component.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

/*****************************************
  Jenkins VPC
 *****************************************/
module "jenkins-vpc" {
  source  = "terraform-google-modules/network/google"

  project_id   = module.enables-google-apis.project_id
  network_name = var.network_name

  subnets = [
    {
      subnet_name   = var.subnet_name
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${var.subnet_name}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

/*****************************************
  Jenkins GKE
 *****************************************/
module "jenkins-gke" {
  source                   = "terraform-google-modules/kubernetes-engine/google"
  project_id               = module.enables-google-apis.project_id
  name                     = "jenkins"
  regional                 = false
  region                   = var.region
  zones                    = var.zones
  network                  = module.jenkins-vpc.network_name
  subnetwork               = module.jenkins-vpc.subnets_names[0]
  ip_range_pods            = var.ip_range_pods_name
  ip_range_services        = var.ip_range_services_name
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  remove_default_node_pool = true
  identity_namespace       = "${module.enables-google-apis.project_id}.svc.id.goog"
  node_metadata            = "GKE_METADATA_SERVER"
  node_pools = [
    {
      name         = "butler-pool"
      min_count    = 3
      max_count    = 6
      auto_upgrade = true
    }
  ]
}

/*****************************************
  IAM Bindings GKE SVC
 *****************************************/
# allow GKE to pull images from GCR
resource "google_project_iam_member" "gke" {
  project = module.enables-google-apis.project_id
  role    = "roles/storage.objectViewer"

  member = "serviceAccount:${module.jenkins-gke.service_account}"
}

