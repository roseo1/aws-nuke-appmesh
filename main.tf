resource "aws_appmesh_mesh" "this" {
  name  = "example"

  spec {
    egress_filter {
      type = "ALLOW_ALL"
    }
  }
}

resource "aws_appmesh_virtual_gateway" "this" {
  name      = "example"
  mesh_name = aws_appmesh_mesh.this.id

  spec {
    listener {
      port_mapping {
        port     = 3000
        protocol = "http"
      }
    }
  }
}

resource "aws_appmesh_gateway_route" "this" {
  mesh_name            = aws_appmesh_mesh.this.id
  name                 = "example"
  virtual_gateway_name = aws_appmesh_virtual_gateway.this.name
  spec {
    http_route {
      action {
        target {
          virtual_service {
            virtual_service_name = aws_appmesh_virtual_service.this.name
          }
        }
        rewrite {
          prefix {
            value = "/"
          }
        }
      }
      match {
        prefix = "/foo/"
      }
    }
  }
}

resource "aws_appmesh_virtual_router" "this" {
  name      = "example"
  mesh_name = aws_appmesh_mesh.this.id
  spec {
    listener {
      port_mapping {
        port     = 3000
        protocol = "http"
      }
    }
  }
}

resource "aws_appmesh_route" "this" {
  name                = "example"
  mesh_name           = aws_appmesh_mesh.this.id
  virtual_router_name = aws_appmesh_virtual_router.this.name

  spec {
    http_route {
      match {
        prefix = "/"
      }

      action {
        weighted_target {
          virtual_node = aws_appmesh_virtual_node.service.name
          weight       = 100
        }
      }
    }
  }
}

resource "aws_appmesh_virtual_service" "this" {
  name      = "example.${data.aws_route53_zone.cloudmap.name}"
  mesh_name = aws_appmesh_mesh.this.id

  spec {
    provider {
      virtual_router {
        virtual_router_name = aws_appmesh_virtual_router.this.name
      }
    }
  }
}

resource "aws_appmesh_virtual_node" "service" {
  mesh_name = aws_appmesh_mesh.this.id
  name      = "example"

  spec {
    backend {
      virtual_service {
        virtual_service_name = aws_appmesh_virtual_service.this.name
      }
    }

    listener {
      port_mapping {
        port     = 3000
        protocol = "http"
      }
    }

    service_discovery {
      aws_cloud_map {
        service_name   = "example"
        namespace_name = data.aws_route53_zone.cloudmap.name
      }
    }
  }
}
