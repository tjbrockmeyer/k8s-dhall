let Map = ../ext/Prelude/Map/Type.dhall

let Map/Entry = ../ext/Prelude/Map/Entry.dhall

let Env = ../utils/Env.dhall

let Service = ./Service.dhall

let Deployment = ./Deployment.dhall

let List/null = ../ext/Prelude/List/null.dhall

let List/map = ../ext/Prelude/List/map.dhall

let k8s/Service = ../ext/k8s/Service.dhall

let k8s/Ingress = ../ext/k8s/Ingress.dhall

let Ingress = ./Ingress.dhall

let Config =
      { Type =
          { name : Text
          , replicas : Natural
          , image : Text
          , env : Map Text Env
          , ports : List Natural
          , hosts : Map Text Natural
          }
      , default =
        { ports = [] : List Natural
        , env = [] : Map Text Env
        , hosts = [] : Map Text Natural
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
            if        List/null Natural config.ports
                  &&  List/null (Map/Entry Text Natural) config.hosts
            then  None k8s/Service.Type
            else  Some
                    ( Service.new
                        Service.Config::{
                        , name = config.name
                        , ports =
                              config.ports
                            # List/map
                                (Map/Entry Text Natural)
                                Natural
                                (\(e : Map/Entry Text Natural) -> e.mapValue)
                                config.hosts
                        }
                    )
        , ingress =
            if    List/null (Map/Entry Text Natural) config.hosts
            then  None k8s/Ingress.Type
            else  Some
                    ( Ingress.new
                        Ingress.Config::{
                        , name = config.name
                        , rules =
                            List/map
                              (Map/Entry Text Natural)
                              Ingress.Rule
                              ( \(e : Map/Entry Text Natural) ->
                                  { host = e.mapKey
                                  , port = e.mapValue
                                  , serviceName = config.name
                                  }
                              )
                              config.hosts
                        }
                    )
        }

in  { Config, new }
