################################################################################
# VPC
################################################################################
variable "vpc_config" {
  description = "Configuration for the VPC module"
  type = object({
    # general
    name = string,
    region = string,
    create_vpc = optinal(bool, true),
    cidr = optional(string, "10.0.0.0/16"),
    secondary_cidr_blocks = optional(list(string), []),
    instance_tenancy = optional(string, "default"),
    asz = optional(list(string), []),
  
    # dns
    enable_dns_hostnames = optional(bool, true),
    enable_dns_support = optional(bool, true),
    enable_network_address_usage_metrics = optional(bool),

    # ip
    use_ipam_pool = optional(bool, false),
    ipv4_ipam_pool_id = optional(string),
    ipv4_netmask_length = optional(number),
    enable_ipv6 = optional(bool, false),
    ipv6_cidr = optional(string),
    ipv6_ipam_pool_id = optional(string),
    ipv6_netmask_length = optional(number),
    ipv6_cidr_block_network_border_group = optional(string),

    # subnets
    subnet = list(object({
      name = string,
      cidr_block = string,
      suffix = optional(string),
      assign_ipv6_address_on_creation = optional(bool, false),
      enable_dns_support = optional(bool, true),
      enable_resource_name_dns_aaaa_record_on_launch = optional(bool, true),
      enable_resource_name_dns_a_record_on_launch = optional(bool, false),
      create_multiple_public_route_tables = optional(bool, false),
      ipv6_prefixes = optional(list(string), []),
      ipv6_native = optional(bool, false),
      map_public_ip_on_launch = optional(bool, false),
      private_dns_hostname_type_on_launch = optional(string),
      tags = optional(map(string), {}),
      tags_per_az = optional(map(map(string), {})),
    })),

    # route table
    route_table = list(object({
      manage_default_route_table = optional(bool, true),
      default_route_table_name = optional(string),
      default_route_table_propagating_vgws = optional(list(string), []),
      default_route_table_routes = optional(list(map(string)), []),
      default_route_table_tags = optional(map(string), {}),
    })),

    # acls
    acls = list(object({
      dedicated_network_acl = optional(bool, false),
      inbound_acl_rules = optional(list(map(string)), [{
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      }]),
      outbound_acl_rules = optional(list(map(string)), [{
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      }])
      acl_tags = optional(map(string), {}),
    })),

    # dhcp
    dhcp = object({
      name = string,
      enable_dhcp_options = optional(bool, false),
      dhcp_options_domain_name = string,
      dhcp_options_domain_name_servers = optional(list(string), ["AmazonProvidedDNS"]),
      dhcp_options_ntp_servers = optional(list(string), []),
      dhcp_options_netbios_name_servers = optional(list(string), []),
      dhcp_options_netbios_node_type = optional(string),
      dhcp_options_ipv6_address_preferred_lease_time = optional(number),
      dhcp_options_tags = optional(map(string), {}),
    }),

    # internet gateway
    igw = object({
      create_igw = optional(bool, true),
      name = string,
      create_egress_only_igw = optional(bool, true),
      igw_tags = optional(map(string), {}),
    }),

    # nat gateway
    nat = object({
      name = string,
      enable_nat_gateway = optional(bool, false),
      nat_gateway_destination_cidr_block = optional(string, ""),
      single_nat_gateway = optional(bool, false),
      one_nat_gateway_per_az = optional(bool, false),
      reuse_nat_ips = optional(bool, false),
      external_nat_ip_ids = optional(list(string), []),
      external_nat_ips = optional(list(string), []),
      nat_gateway_tags = optional(map(string), {}),
      nat_eip_tags = optional(map(string), {}),
    }),
  
    # tags
    vpc_tags = optional(map(string), {}),
    tags = optional(map(string), {}),
  })
}
