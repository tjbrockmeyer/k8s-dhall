let Map = ../ext/Prelude/Map/Type.dhall

let Env = ../utils/Env.dhall

let Service = ./Service.dhall

let Deployment = ./Deployment.dhall

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
        { deployment =
            Deployment.new
              Deployment.Config::{
              , name = config.name
              , replicas = config.replicas
              , image = config.image
              , ports = config.ports
              , env = config.env
              }
        , service =
            Service.new
              Service.Config::{ name = config.name, ports = config.ports }
        }

in  { Config, new }
