let Namespace = ../kd/constructs/Namespace.dhall

in  [ Namespace.new Namespace.Config::{ name = "dev" }
    , Namespace.new Namespace.Config::{ name = "prod" }
    ]
