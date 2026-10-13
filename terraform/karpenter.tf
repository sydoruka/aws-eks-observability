module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.0"

  cluster_name                    = module.eks_al2023.cluster_name
  create_pod_identity_association = true
  enable_inline_policy            = true
  node_iam_role_name              = "${local.name}-al2023-karpenter"
  node_iam_role_use_name_prefix   = false

  tags = local.tags
}

resource "helm_release" "karpenter" {
  namespace           = "kube-system"
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.karpenter.user_name
  repository_password = data.aws_ecrpublic_authorization_token.karpenter.password
  chart               = "karpenter"
  version             = "1.6.0"

  values = [
    yamlencode({
      replicas = 1
      nodeSelector = {
        "karpenter.sh/controller" = "true"
      }
      dnsPolicy = "Default"
      settings = {
        clusterName       = module.eks_al2023.cluster_name
        clusterEndpoint   = module.eks_al2023.cluster_endpoint
        interruptionQueue = module.karpenter.queue_name
      }
      webhook = {
        enabled = false
      }
    })
  ]

  depends_on = [module.eks_al2023, module.karpenter]
}

