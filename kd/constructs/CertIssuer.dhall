let Config =
      { Type = { name : Text, namespace : Text, server : Text, email : Text }
      , default = {=}
      }

let new =
      \(config : Config.Type) ->
        { apiVersion = "cert-manager.io/v1"
        , kind = "Issuer"
        , metadata = { name = config.name, namespace = config.namespace }
        , spec.acme
          =
          { server = config.server
          , email = config.email
          , privateKeySecretRef.name = config.name
          , solvers = [ { http01.ingress.ingressClassName = "nginx" } ]
          }
        }

in  { Config, new }
