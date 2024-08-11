variable "cloud9" {
    description = "Configs for Cloud9 environment"
    type = object({
        name = string
        instance_type = string
        image_id = string
        region = string
        subnet_id = string
    })
}
