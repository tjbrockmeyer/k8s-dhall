let List/all = ../ext/Prelude/List/map.dhall

let Map = ../ext/Prelude/List/map.dhall

let Optional/default = ../ext/Prelude/Optional/default.dhall

let Optional/null = ../ext/Prelude/Optional/null.dhall

let Bool/not = ../ext/Prelude/Bool/not.dhall

let k8s/Secret = ../ext/k8s/Secret.dhall

let k8s/ObjectMeta = ../ext/k8s/ObjectMeta.dhall

let Config =
      { Type = { name : Text, data : Map Text (Optional Text) }, default = {=} }

let new =
      \(config : Config.Type) ->
        let isValid =
              List/all
                { mapKey : Text, mapValue : Optional Text }
                ( \(s : { mapKey : Text, mapValue : Optional Text }) ->
                    Bool/not (Optional/null Text s.mapValue)
                )
                config.data

        let mappedData =
              List/map
                { mapKey : Text, mapValue : Optional Text }
                { mapKey : Text, mapValue : Text }
                ( \(s : { mapKey : Text, mapValue : Optional Text }) ->
                    { mapKey = s.mapKey
                    , mapValue = Optional/default Text "<no-value>" s.mapValue
                    }
                )
                config.data

        in  if    Bool/not isValid
            then  None k8s/Secret.Type
            else  Some
                    k8s/Secret::{
                    , apiVersion = "v1"
                    , kind = "Secret"
                    , metadata = k8s/ObjectMeta::{ name = Some config.name }
                    , type = Some "Opaque"
                    , data = Some mappedData
                    }

in  { Config, new }
