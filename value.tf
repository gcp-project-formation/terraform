variable "ecm_provider" {
  type = object({
    project     = string
    region      = string
    zone        = string
    credentials = string
  })
  default = {
    project     = "formationgcp",
    region      = "europe-west3",
    zone        = "europe-west3-b",
    credentials = "./key.json"
  }
}

variable "ecm_compute_network" {
  type = object({
    vpc_name = string
    regions = object({
      region_subnet_1 = string
      region_subnet_2 = string
    }),
    zones = object({
      zone_subnet_1 = string
      zone_subnet_2 = string
      zone_subnet_3 = string
    }),
    subnetwork = object({
      names = object({
        subnet_ecm_name_1 = string
        subnet_ecm_name_2 = string
      })
      ip_ranges = object({
        ip_range_subnet_1 = string
        ip_range_subnet_2 = string
      })
    }),
    endpoint_group = object({
      names = object({
        lb_neg_name_1 = string
        lb_neg_name_2 = string
        lb_neg_name_3 = string
      })
      port = string
    })
  })
  default = {
    vpc_name = "vpc-ecm",
    regions = {
      region_subnet_1 = "europe-west3",
      region_subnet_2 = "europe-west2"
    },
    zones = {
      zone_subnet_1 = "europe-west3-b",
      zone_subnet_2 = "europe-west3-c",
      zone_subnet_3 = "europe-west2-a"
    },
    subnetwork = {
      names = {
        subnet_ecm_name_1 = "subnet-ecm-1",
        subnet_ecm_name_2 = "subnet-ecm-2"
      }
      ip_ranges = {
        ip_range_subnet_1 = "10.0.1.0/24",
        ip_range_subnet_2 = "10.0.2.0/24"
      }
    },
    endpoint_group = {
      names = {
        lb_neg_name_1 = "lb-neg-1",
        lb_neg_name_2 = "lb-neg-2",
        lb_neg_name_3 = "lb-neg-3"
      },
      port = "90"
    }
  }
}

variable "redis_instance_value" {
  type = object({
    name         = string
    machine_type = string
    zone         = string
    region       = string
    tags         = list(string)
    image        = string
    remote_exec = object({
      inline   = list(string)
      ssh_name = string
    })
  })
  default = {
    name         = "redis-ecm",
    machine_type = "e2-medium",
    region       = "europe-west2",
    zone         = "europe-west2-a", # "${var.ecm_compute_network.zones.zone_subnet_3}",
    tags         = ["allow-redis"],
    image        = "debian-cloud/debian-11",
    remote_exec = {
      inline   = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"],
      ssh_name = "ssh"
    }
  }
}

variable "bucket_repo_names" {
  type = map(any)
  default = {
    1  = { name = "ad-service", location = "europe-west1", deploy_type = "prod", branch_name = "main" },
    2  = { name = "cart-service", location = "europe-west1", deploy_type = "prod", branch_name = "main" },
    3  = { name = "checkout-service", location = "europe-west1", deploy_type = "prod", branch_name = "main" },
    4  = { name = "currency-service", location = "europe-west1", deploy_type = "prod", branch_name = "main" },
    5  = { name = "email-service", location = "europe-west1", deploy_type = "prod", branch_name = "main" },
    6  = { name = "frontend", location = "europe-west1", deploy_type = "prod", branch_name = "main" },
    7  = { name = "load-generator", location = "europe-west1", deploy_type = "prod", branch_name = "main" },
    8  = { name = "payment-service", location = "europe-west1", deploy_type = "prod", branch_name = "main" },
    9  = { name = "product-catalog-service", location = "europe-west1", deploy_type = "prod", branch_name = "main" },
    10 = { name = "recommendation-service", location = "europe-west1", deploy_type = "prod", branch_name = "main" },
    11 = { name = "shipping-service", location = "europe-west1", deploy_type = "prod", branch_name = "main" }
    # 12 = { name = "ad-service", location = "europe-west3", deploy_type = "dev", branch_name = "dev" },
    # 13 = { name = "cart-service", location = "europe-west3", deploy_type = "dev", branch_name = "dev" },
    # 14 = { name = "checkout-service", location = "europe-west3", deploy_type = "develop", branch_name = "dev" },
    # 15 = { name = "currency-service", location = "europe-west3", deploy_type = "develop", branch_name = "dev" },
    # 16 = { name = "email-service", location = "europe-west3", deploy_type = "develop", branch_name = "dev" },
    # 17 = { name = "frontend", location = "europe-west3", deploy_type = "develop", branch_name = "dev" },
    # 18 = { name = "load-generator", location = "europe-west3", deploy_type = "develop", branch_name = "dev" },
    # 19 = { name = "payment-service", location = "europe-west3", deploy_type = "develop", branch_name = "dev" },
    # 20 = { name = "product-catalog-service", location = "europe-west3", deploy_type = "develop", branch_name = "dev" },
    # 21 = { name = "recommendation-service", location = "europe-west3", deploy_type = "develop", branch_name = "dev" },
    # 22 = { name = "shipping-service", location = "europe-west3", deploy_type = "develop", branch_name = "dev" },
  }
}

variable "container_cluster" {
  type = object({
    name                          = string
    logging_service               = string
    monitoring_service            = string
    networking_mode               = string
    workload_pool                 = string
    channel                       = string
    cluster_secondary_range_name  = string
    services_secondary_range_name = string
    master_ipv4_cidr_block        = string
  })
  default = {
    name                          = "ecm-cluster",
    logging_service               = "logging.googleapis.com/kubernetes",
    monitoring_service            = "monitoring.googleapis.com/kubernetes",
    networking_mode               = "VPC_NATIVE",
    channel                       = "REGULAR",
    workload_pool                 = "formationgcp.svc.id.goog",
    cluster_secondary_range_name  = "k8s-pod-range",
    services_secondary_range_name = "k8s-service-range",
    master_ipv4_cidr_block        = "172.16.0.0/28"
  }
}

variable "cart_service_name" {
  type    = string
  default = "cart-service"
}

variable "bucket_name" {
  type    = string
  default = "ecm-bucket"
}

variable "router_name" {
  type    = string
  default = "router"
}

variable "nat_name" {
  type    = string
  default = "nat"
}
