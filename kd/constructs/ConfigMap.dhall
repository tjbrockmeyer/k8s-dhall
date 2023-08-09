let Map = ../ext/Prelude/Map/Type.dhall

let k8s/ConfigMap = ../ext/k8s/ConfigMap.dhall

let k8s/ObjectMeta = ../ext/k8s/ObjectMeta.dhall

let Config = { Type = { name : Text, data : Map Text Text }, default = {=} }

let new =
      \(config : Config.Type) ->
        k8s/ConfigMap::{
        , apiVersion = "v1"
        , kind = "ConfigMap"
        , data = Some config.data
        , metadata = k8s/ObjectMeta::{ name = Some config.name }
        }

in  { Config, new }
