let List/map = ../ext/Prelude/List/map.dhall

let k8s/Service = ../ext/k8s/Service.dhall

let k8s/ServicePort = ../ext/k8s/ServicePort.dhall

let k8s/ObjectMeta = ../ext/k8s/ObjectMeta.dhall

let k8s/ServiceSpec = ../ext/k8s/ServiceSpec.dhall

let Config =
      { Type = { name : Text, ports : List Natural }
      , default.ports = [] : List Natural
      }

let new =
      \(config : Config.Type) ->
        let ports =
              List/map
                Natural
                k8s/ServicePort.Type
                (\(port : Natural) -> k8s/ServicePort::{ port })
                config.ports

        in  k8s/Service::{
            , apiVersion = "v1"
            , kind = "Service"
            , metadata = k8s/ObjectMeta::{ name = Some config.name }
            , spec = Some k8s/ServiceSpec::{
              , selector = Some (toMap { app = config.name })
              , ports = Some ports
              }
            }

in  { Config, new }
