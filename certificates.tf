resource "tls_private_key" "reg_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.reg_private_key.private_key_pem
  email_address   = "admin@arrival.com"
}

resource "tls_private_key" "cert_private_key" {
  algorithm = "RSA"
}

resource "tls_cert_request" "req_certificate" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.cert_private_key.private_key_pem

  dns_names = [
    "*.${var.dns_zone}",
  ]

  subject {
    common_name = var.dns_zone
  }
}

resource "acme_certificate" "certificates" {
  account_key_pem         = acme_registration.reg.account_key_pem
  certificate_request_pem = tls_cert_request.req_certificate.cert_request_pem

  dns_challenge {
    provider = "gcloud"
    config = {
      GCE_PROJECT = var.google_cloud_project
    }
  }
}
