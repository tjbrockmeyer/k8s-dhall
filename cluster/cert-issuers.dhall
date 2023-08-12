let CertIssuer = ../kd/constructs/CertIssuer.dhall

let email = env:EMAIL as Text

in  [ CertIssuer.new
        CertIssuer.Config::{
        , name = "letsencrypt-staging"
        , namespace = "dev"
        , server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        , email
        }
    , CertIssuer.new
        CertIssuer.Config::{
        , name = "letsencrypt"
        , namespace = "dev"
        , server = "https://acme-v02.api.letsencrypt.org/directory"
        , email
        }
    , CertIssuer.new
        CertIssuer.Config::{
        , name = "letsencrypt"
        , namespace = "prod"
        , server = "https://acme-v02.api.letsencrypt.org/directory"
        , email
        }
    ]
