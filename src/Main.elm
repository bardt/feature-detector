module Main (..) where

import Html exposing (div, table, tbody, tr, td, text)
import StartApp
import Signal exposing (Address)
import Http
import Json.Decode as Json exposing ((:=))
import Task exposing (..)
import Effects exposing (Effects, Never)


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


port tasks : Signal (Task.Task Never ())
port tasks =
    app.tasks


main : Signal Html.Html
main =
    app.html


type alias StatsItem =
    { feature : String
    , enabled : Int
    , total : Int
    }


type alias Stats =
    List StatsItem


type alias Model =
    { stats : Stats }


demoStats : List StatsItem
demoStats =
    [ { feature = "service workers"
      , enabled = 61
      , total = 105
      }
    ]


model : Model
model =
    { stats = demoStats }


appendRight : String -> String -> String
appendRight str1 str2 =
    str2 ++ str1


percentageText : Float -> Html.Html
percentageText percentage =
    percentage
        |> toString
        |> appendRight "%"
        |> text


countPercentage : StatsItem -> Float
countPercentage statsItem =
    (toFloat statsItem.enabled) / (toFloat statsItem.total) * 100


statsTableItem : StatsItem -> Html.Html
statsTableItem statsItem =
    tr
        []
        [ td
            []
            [ text statsItem.feature ]
        , td
            []
            [ percentageText (countPercentage statsItem) ]
        ]


statsTable : Stats -> Html.Html
statsTable stats =
    table
        []
        [ tbody [] (List.map statsTableItem stats)
        ]


view : Address Action -> Model -> Html.Html
view address model =
    div
        []
        [ statsTable model.stats
        ]


type Action
    = ReplaceStats (Maybe Stats)


fetchStats : Effects Action
fetchStats =
    Http.get statsDecoder "http://localhost:5000/stats"
        |> Task.toMaybe
        |> Task.map ReplaceStats
        |> Effects.task
        |> Debug.log "fetchStats"


statsDecoder : Json.Decoder Stats
statsDecoder =
    let
        statItemDecoder =
            Json.object3
                StatsItem
                ("feature" := Json.string)
                ("enabled" := Json.int)
                ("total" := Json.int)
    in
        Json.list statItemDecoder


update : Action -> Model -> ( Model, Effects Action )
update action model =
    case action of
        ReplaceStats stats ->
            ( { model | stats = (Maybe.withDefault model.stats stats) }, Effects.none )
