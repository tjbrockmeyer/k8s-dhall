let k8s/Ingress = ../ext/k8s/Ingress.dhall

let k8s/IngressSpec = ../ext/k8s/IngressSpec.dhall

let k8s/ObjectMeta = ../ext/k8s/ObjectMeta.dhall

let k8s/HTTPIngressRuleValue = ../ext/k8s/HTTPIngressRuleValue.dhall

let k8s/HTTPIngressPath = ../ext/k8s/HTTPIngressPath.dhall

let k8s/IngressBackend = ../ext/k8s/IngressBackend.dhall

let k8s/IngressServiceBackend = ../ext/k8s/IngressServiceBackend.dhall

let k8s/IngressRule = ../ext/k8s/IngressRule.dhall

let k8s/ServiceBackendPort = ../ext/k8s/ServiceBackendPort.dhall

let k8s/IngressTLS = ../ext/k8s/IngressTLS.dhall

let List/map = ../ext/Prelude/List/map.dhall

let Map = ../ext/Prelude/Map/Type.dhall

let Rule =
      { host : Text, certSecret : Text, serviceName : Text, port : Natural }

let Config = { Type = { name : Text, rules : List Rule }, default = {=} }

let new =
      \(config : Config.Type) ->
        k8s/Ingress::{
        , apiVersion = "networking.k8s.io/v1"
        , kind = "Ingress"
        , metadata = k8s/ObjectMeta::{
          , name = Some config.name
          , labels = Some (toMap { app = config.name })
          , annotations = Some (toMap {=} : Map Text Text)
          }
        , spec = Some k8s/IngressSpec::{
          , rules = Some
              ( List/map
                  Rule
                  k8s/IngressRule.Type
                  ( \(rule : Rule) ->
                      k8s/IngressRule::{
                      , host = Some rule.host
                      , http = Some k8s/HTTPIngressRuleValue::{
                        , paths =
                          [ k8s/HTTPIngressPath::{
                            , pathType = "Prefix"
                            , backend = k8s/IngressBackend::{
                              , service = Some k8s/IngressServiceBackend::{
                                , name = rule.serviceName
                                , port = Some k8s/ServiceBackendPort::{
                                  , number = Some rule.port
                                  }
                                }
                              }
                            }
                          ]
                        }
                      }
                  )
                  config.rules
              )
          , tls = Some
              ( List/map
                  Rule
                  k8s/IngressTLS.Type
                  ( \(rule : Rule) ->
                      { hosts = Some [ rule.host ]
                      , secretName = Some rule.certSecret
                      }
                  )
                  config.rules
              )
          }
        }

in  { Config, Rule, new }
