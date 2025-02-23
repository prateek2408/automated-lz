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

output "kubernetes_endpoint" {
  description = "The cluster endpoint"
  sensitive   = true
  value       = module.jenkins-gke.endpoint
}

output "ca_certificate" {
  description = "The cluster ca certificate (base64 encoded)"
  sensitive   = true
  value       = module.jenkins-gke.ca_certificate
}

output "service_account" {
  description = "The default service account used for running nodes."
  value       = module.jenkins-gke.service_account
}

output "cluster_name" {
  description = "Cluster name"
  value       = module.jenkins-gke.name
}

#output "k8s_service_account_name" {
#  description = "Name of k8s service account."
#  value       = module.workload_identity.k8s_service_account_name
#}

#output "gcp_service_account_email" {
#  description = "Email address of GCP service account."
#  value       = module.workload_identity.gcp_service_account_email
#}

output "jenkins_k8s_config_secrets" {
  description = "Name of the secret required to configure k8s executers on Jenkins"
  value       = var.jenkins_k8s_config
}

output "jenkins_project_id" {
  description = "Project id of Jenkins GKE project"
  value       = module.enables-google-apis.project_id
}

output "zone" {
  description = "Zone of Jenkins GKE cluster"
  value       = join(",", var.zones)
}
