let k8s/EnvVar = ../ext/k8s/EnvVar.dhall

let k8s/EnvVarSource = ../ext/k8s/EnvVarSource.dhall

let k8s/ConfigMapKeySelector = ../ext/k8s/ConfigMapKeySelector.dhall

let k8s/SecretKeySelector = ../ext/k8s/SecretKeySelector.dhall

let Env = ./Env.dhall

in  \(env : { name : Text, value : Env }) ->
      merge
        { Value = \(t : Text) -> k8s/EnvVar::{ name = env.name, value = Some t }
        , Config =
            \(c : { name : Text, key : Text }) ->
              k8s/EnvVar::{
              , name = env.name
              , valueFrom = Some k8s/EnvVarSource::{
                , configMapKeyRef = Some k8s/ConfigMapKeySelector::{
                  , name = Some c.name
                  , key = c.key
                  }
                }
              }
        , Secret =
            \(c : { name : Text, key : Text }) ->
              k8s/EnvVar::{
              , name = env.name
              , valueFrom = Some k8s/EnvVarSource::{
                , secretKeyRef = Some k8s/SecretKeySelector::{
                  , name = Some c.name
                  , key = c.key
                  }
                }
              }
        }
        env.value
