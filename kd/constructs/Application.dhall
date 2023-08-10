let Map = ../ext/Prelude/Map/Type.dhall

let Env = ../utils/Env.dhall

let Service = ./Service.dhall

let Deployment = ./Deployment.dhall

let List/null = ../ext/Prelude/List/null.dhall

let List/map = ../ext/Prelude/List/map.dhall

let k8s/Service = ../ext/k8s/Service.dhall

let k8s/Ingress = ../ext/k8s/Ingress.dhall

let Ingress = ./Ingress.dhall

let Host = { name : Text, certSecret : Text, port : Natural }

let Config =
      { Type =
          { name : Text
          , replicas : Natural
          , image : Text
          , env : Map Text Env
          , ports : List Natural
          , hosts : List Host
          }
      , default =
        { ports = [] : List Natural
        , env = [] : Map Text Env
        , hosts = [] : List Host
        }
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
            if    List/null Natural config.ports && List/null Host config.hosts
            then  None k8s/Service.Type
            else  Some
                    ( Service.new
                        Service.Config::{
                        , name = config.name
                        , ports =
                              config.ports
                            # List/map
                                Host
                                Natural
                                (\(host : Host) -> host.port)
                                config.hosts
                        }
                    )
        , ingress =
            if    List/null Host config.hosts
            then  None k8s/Ingress.Type
            else  Some
                    ( Ingress.new
                        Ingress.Config::{
                        , name = config.name
                        , rules =
                            List/map
                              Host
                              Ingress.Rule
                              ( \(host : Host) ->
                                  { host = host.name
                                  , port = host.port
                                  , certSecret = host.certSecret
                                  , serviceName = config.name
                                  }
                              )
                              config.hosts
                        }
                    )
        }

in  { Config, new }
