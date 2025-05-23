# "Left" region

resource "openstack_vpnaas_ike_policy_v2" "ike_policy_left" {
  name = var.ike_policy_name
}

resource "openstack_vpnaas_ipsec_policy_v2" "ipsec_policy_left" {
  name = var.ipsec_policy_name
}

resource "openstack_vpnaas_service_v2" "vpn_service_left" {
  name = var.vpn_service_name
  router_id = openstack_networking_router_v2.router.id
  admin_state_up = "true"
}

resource "openstack_vpnaas_endpoint_group_v2" "epg_subnet_left" {
  name = var.epg_subnet_name
  type = "subnet"
  endpoints = [openstack_networking_subnet_v2.subnet_ipv4.id,]
}

resource "openstack_vpnaas_endpoint_group_v2" "epg_cidr_right" {
  name = var.epg_cidr_name
  type = "cidr"
  endpoints = [openstack_networking_subnet_v2.subnet_ipv4_right.cidr,]
}

resource "openstack_vpnaas_site_connection_v2" "conn_left" {
  name = var.vpn_connection_name
  ikepolicy_id = openstack_vpnaas_ike_policy_v2.ike_policy_left.id
  ipsecpolicy_id = openstack_vpnaas_ipsec_policy_v2.ipsec_policy_left.id
  vpnservice_id = openstack_vpnaas_service_v2.vpn_service_left.id
  psk = var.psk
  peer_id = openstack_vpnaas_service_v2.vpn_service_right.external_v4_ip
  peer_address = openstack_vpnaas_service_v2.vpn_service_right.external_v4_ip
  local_ep_group_id = openstack_vpnaas_endpoint_group_v2.epg_subnet_left.id
  peer_ep_group_id  = openstack_vpnaas_endpoint_group_v2.epg_cidr_right.id
  depends_on  = [openstack_networking_router_interface_v2.router_interface_ipv4]
}

# "Right" region

resource "openstack_vpnaas_ike_policy_v2" "ike_policy_right" {
  name = var.ike_policy_name
  provider = openstack.right
}

resource "openstack_vpnaas_ipsec_policy_v2" "ipsec_policy_right" {
  name = var.ipsec_policy_name
  provider = openstack.right
}

resource "openstack_vpnaas_service_v2" "vpn_service_right" {
  name = var.vpn_service_name
  router_id = openstack_networking_router_v2.router_right.id
  admin_state_up = "true"
  provider = openstack.right
}

resource "openstack_vpnaas_endpoint_group_v2" "epg_subnet_right" {
  name = var.epg_subnet_name
  type = "subnet"
  endpoints = [openstack_networking_subnet_v2.subnet_ipv4_right.id,]
  provider = openstack.right
}

resource "openstack_vpnaas_endpoint_group_v2" "epg_cidr_left" {
  name = var.epg_cidr_name
  type = "cidr"
  endpoints = [openstack_networking_subnet_v2.subnet_ipv4.cidr,]
  provider = openstack.right
}

resource "openstack_vpnaas_site_connection_v2" "conn_right" {
  name = var.vpn_connection_name
  ikepolicy_id = openstack_vpnaas_ike_policy_v2.ike_policy_right.id
  ipsecpolicy_id = openstack_vpnaas_ipsec_policy_v2.ipsec_policy_right.id
  vpnservice_id = openstack_vpnaas_service_v2.vpn_service_right.id
  psk = var.psk
  peer_id = openstack_vpnaas_service_v2.vpn_service_left.external_v4_ip
  peer_address = openstack_vpnaas_service_v2.vpn_service_left.external_v4_ip
  local_ep_group_id = openstack_vpnaas_endpoint_group_v2.epg_subnet_right.id
  peer_ep_group_id  = openstack_vpnaas_endpoint_group_v2.epg_cidr_left.id
  provider = openstack.right
  depends_on  = [openstack_networking_router_interface_v2.router_interface_ipv4_right]
}
