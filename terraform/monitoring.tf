resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  chart            = "${path.module}/../helm-charts/kube-prometheus-stack"

  wait            = true
  timeout         = 600
  atomic          = true
  cleanup_on_fail = true

  depends_on = [module.eks_al2023]
}

resource "helm_release" "alloy" {
  name             = "alloy"
  namespace        = "monitoring"
  create_namespace = true
  chart            = "${path.module}/../helm-charts/alloy"

  wait            = true
  timeout         = 600
  atomic          = true
  cleanup_on_fail = true

  depends_on = [module.eks_al2023]
}