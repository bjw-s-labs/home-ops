locals {
  networks = yamldecode(chomp(data.http.bjws_common_networks.response_body))
}
