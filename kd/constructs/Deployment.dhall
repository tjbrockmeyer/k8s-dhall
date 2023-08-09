let Map = ../ext/Prelude/Map/Type.dhall

let List/map = ../ext/Prelude/List/map.dhall

let Env = ../utils/Env.dhall

let transformEnv = ../utils/transformEnv.dhall

let k8s/EnvVar = ../ext/k8s/EnvVar.dhall

let k8s/ObjectMeta = ../ext/k8s/ObjectMeta.dhall

let k8s/Container = ../ext/k8s/Container.dhall

let k8s/ContainerPort = ../ext/k8s/ContainerPort.dhall

let k8s/Deployment = ../ext/k8s/Deployment.dhall

let k8s/DeploymentSpec = ../ext/k8s/DeploymentSpec.dhall

let k8s/LabelSelector = ../ext/k8s/LabelSelector.dhall

let k8s/PodTemplateSpec = ../ext/k8s/PodTemplateSpec.dhall

let k8s/PodSpec = ../ext/k8s/PodSpec.dhall

let Config =
      { Type =
          { name : Text
          , replicas : Natural
          , image : Text
          , ports : List Natural
          , env : Map Text Env
          }
      , default = { ports = [] : List Natural, env = [] : Map Text Env }
      }

let new =
      \(config : Config.Type) ->
        let ports =
              List/map
                Natural
                k8s/ContainerPort.Type
                ( \(port : Natural) ->
                    k8s/ContainerPort::{ containerPort = port }
                )
                config.ports

        let env =
              List/map
                { mapKey : Text, mapValue : Env }
                k8s/EnvVar.Type
                ( \(item : { mapKey : Text, mapValue : Env }) ->
                    transformEnv { name = item.mapKey, value = item.mapValue }
                )
                config.env

        in  k8s/Deployment::{
            , apiVersion = "apps/v1"
            , kind = "Deployment"
            , metadata = k8s/ObjectMeta::{
              , name = Some config.name
              , labels = Some (toMap { app = config.name })
              }
            , spec = Some k8s/DeploymentSpec::{
              , replicas = Some config.replicas
              , selector = k8s/LabelSelector::{
                , matchLabels = Some (toMap { app = config.name })
                }
              , template = k8s/PodTemplateSpec::{
                , metadata = Some k8s/ObjectMeta::{
                  , labels = Some (toMap { app = config.name })
                  }
                , spec = Some k8s/PodSpec::{
                  , containers =
                    [ k8s/Container::{
                      , name = config.name
                      , image = Some config.image
                      , ports = Some ports
                      , env = Some env
                      }
                    ]
                  }
                }
              }
            }

in  { Config, new }
