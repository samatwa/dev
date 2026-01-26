resource "helm_release" "argo_cd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = var.namespace
  version    = var.chart_version

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "helm_release" "argo_apps" {
  name      = "argo-apps"
  chart     = "${path.module}/charts"
  namespace = var.namespace

  values = [
    "${path.module}/charts/values.yaml"
  ]
}
