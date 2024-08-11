variable "eks_config" {
  description = "Configuration for the EKS module"
  type = object({
    name = string
    version = string
    add_ons = optional(list(object({
      name = string
      version = optional(string)
    })), [
      {
        name = "kube-proxy"
      },
      {
        name = "vpc-cni"
      },
      {
        name = "coredns"
      },
      {
        name = "aws-ebs-csi-driver"
      }
    ]
  )})
}

variable "role_policies" {
  description = "IAM policies to attach to the EKS service role"
  type = object({
    eks_cluster_role = optional(list(object({
      name = string
      arn  = string
    })), [
      {
        name = "AmazonEKSClusterPolicy"
        arn  = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
      },
      {
        name = "AmazonEKSVPCResourceController"
        arn  = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
      }
    ])
    node_role = optional(list(object({
      name  = string
      arn   = string
    })), [
      {
        name = "AmazonEKSWorkerNodePolicy"
        arn  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      },
      {
        name = "AmazonSSMManagedInstanceCore"
        arn  = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      },
      {
        name = "AmazonEKS_CNI_Policy"
        arn  = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      },
      {
        name = "AmazonEC2ContainerRegistryReadOnly"
        arn  = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }    
    ])
  })
}