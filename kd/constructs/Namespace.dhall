let k8s/Namespace = ../ext/k8s/Namespace.dhall

let k8s/ObjectMeta = ../ext/k8s/ObjectMeta.dhall

let Config = { Type = { name : Text }, default = {=} }

let new =
      \(config : Config.Type) ->
        k8s/Namespace::{
        , apiVersion = "v1"
        , kind = "Namespace"
        , metadata = k8s/ObjectMeta::{
          , name = Some config.name
          , labels = Some (toMap { name = config.name })
          }
        }

in  { Config, new }
