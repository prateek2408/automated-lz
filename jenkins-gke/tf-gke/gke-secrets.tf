/*****************************************
  K8S secrets for configuring K8S executers
 *****************************************/
resource "kubernetes_secret" "jenkins-secrets" {
  metadata {
    name = var.jenkins_k8s_config
  }
  data = {
    project_id          = module.enables-google-apis.project_id
    kubernetes_endpoint = "https://${module.jenkins-gke.endpoint}"
    ca_certificate      = module.jenkins-gke.ca_certificate
    jenkins_tf_ksa      = module.workload_identity.k8s_service_account_name
  }
}

/*****************************************
  K8S secrets for GH
 *****************************************/
resource "kubernetes_secret" "gh-secrets" {
  metadata {
    name = "github-secrets"
  }
  data = {
    github_username = var.github_username
    github_repo     = var.github_repo
    github_token    = var.github_token
  }
}
