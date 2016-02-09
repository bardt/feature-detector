module Main (..) where

import Html
import Task exposing (Task)
import Effects exposing (Effects, Never)
import StartApp
import Model exposing (Model, model)
import View exposing (view)
import Update exposing (Action, update)
import API exposing (fetchStats)


init : ( Model, Effects Action )
init =
    ( model, fetchStats )


app : StartApp.App Model
app =
    StartApp.start
        { init = init
        , view = view
        , update = update
        , inputs = []
        }


port tasks : Signal (Task Never ())
port tasks =
    app.tasks


main : Signal Html.Html
main =
    app.html
