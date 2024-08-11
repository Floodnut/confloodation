################################################################################
# VPC
################################################################################
resource "aws_vpc" "this" {
  cidr_block          = var.vpc_config.use_ipam_pool ? null : var.vpc_config.cidr
  ipv4_ipam_pool_id   = var.vpc_config.ipv4_ipam_pool_id
  ipv4_netmask_length = var.vpc_config.ipv4_netmask_length

  assign_generated_ipv6_cidr_block     = var.vpc_config.enable_ipv6 && !var.vpc_config.use_ipam_pool ? true : null
  ipv6_cidr_block                      = var.vpc_config.ipv6_cidr
  ipv6_ipam_pool_id                    = var.vpc_config.ipv6_ipam_pool_id
  ipv6_netmask_length                  = var.vpc_config.ipv6_netmask_length
  ipv6_cidr_block_network_border_group = var.vpc_config.ipv6_cidr_block_network_border_group

  instance_tenancy                     = var.vpc_config.instance_tenancy
  enable_dns_hostnames                 = var.vpc_config.enable_dns_hostnames
  enable_dns_support                   = var.vpc_config.enable_dns_support
  enable_network_address_usage_metrics = var.vpc_config.enable_network_address_usage_metrics

  tags = merge(
    { "Name" = var.vpc_config.name },
    var.vpc_config.tags,
    var.vpc_config.vpc_tags,
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = length(var.vpc_config.secondary_cidr_blocks) > 0 ? length(var.vpc_config.secondary_cidr_blocks) : 0
  vpc_id = aws_vpc.this.id
  cidr_block = element(var.vpc_config.secondary_cidr_blocks, count.index)
}

################################################################################
# DHCP Options Set
################################################################################
resource "aws_vpc_dhcp_options" "this" {
  count = var.vpc_config.dhcp.enable_dhcp_options ? 1 : 0

  domain_name                       = var.vpc_config.dhcp.dhcp_options_domain_name
  domain_name_servers               = var.vpc_config.dhcp.dhcp_options_domain_name_servers
  ntp_servers                       = var.vpc_config.dhcp.dhcp_options_ntp_servers
  netbios_name_servers              = var.vpc_config.dhcp.dhcp_options_netbios_name_servers
  netbios_node_type                 = var.vpc_config.dhcp.dhcp_options_netbios_node_type
  ipv6_address_preferred_lease_time = var.vpc_config.dhcp.dhcp_options_ipv6_address_preferred_lease_time

  tags = merge(
    { "Name" = var.vpc_config.dhcp.name },
    var.vpc_config.dhcp.tags,
    var.vpc_config.dhcp.dhcp_options_tags,
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = var.vpc_config.dhcp.enable_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this.id
}

################################################################################
# Subnets
################################################################################
resource "aws_subnet" "this" {  
  for_each = { for subnet in var.vpc_config.subnets : "${subnet.az}_${subnet.suffix}" => {
    cidr_block = subnet.cidr_block
    az         = subnet.az
    suffix     = subnet.suffix
    tags       = merge(subnet.tags, subnet.tags_per_az)
  }}

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = "${var.config.region}${each.value.az}"

  tags = merge(
    var.vpc_config.tags,
    each.value.tags,
    {
      Name = "${var.vpc_config.name}-${each.value.az}-${each.value.suffix}" 
    },
  )
}

################################################################################
# Route Table
################################################################################
resource "aws_route_table" "this" {
  for_each = { for route_table in var.vpc_config.route_tables : route_table.suffix => route_table }

  vpc_id   = aws_vpc.this.id

  tags = merge(
    var.vpc_config.tags,
    each.value.default_route_table_tags,
    {
      Name = "${var.vpc_config.name}-rt-${each.value.suffix}"
    }
  )
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}

resource "aws_route" "public_internet_gateway" {
  count = var.igw_config.create_igw

  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "public_internet_gateway_ipv6" {
  count = var.igw_config.create_igw && var.vpc_config.enable_ipv6 ? 1 : 0

  route_table_id              = aws_route_table.this.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this.id
}


################################################################################
# Internet Gateway
################################################################################
resource "aws_internet_gateway" "this" {
  count = var.igw_config.create_igw ? 1 : 0

  vpc_id = aws_vpc.this.vpc_id

  tags = merge(
    var.igw_config.igw_tags,
    { "Name" = var.igw_config.name },
  )
}

resource "aws_egress_only_internet_gateway" "this" {
  count = var.igw_config.create_egress_only_igw && var.vpc_config.enable_ipv6 ? 1 : 0

  vpc_id = aws_vpc.this.vpc_id

  tags = merge(
    var.igw_config.igw_tags,
    { "Name" = var.igw_config.name },
  )
}

resource "aws_route" "private_ipv6_egress" {
  count = var.igw_config.create_egress_only_igw && var.vpc_config.enable_ipv6 ? 1 : 0

  route_table_id              = aws_route_table.this.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.this.id
}

################################################################################
# Nat Gateway
################################################################################

# Todo: Add support for multiple NAT gateways