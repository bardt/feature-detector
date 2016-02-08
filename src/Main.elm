module Main (..) where

import String
import Html exposing (div, table, tbody, tr, td, text)
import StartApp
import Signal exposing (Address)
import Http
import Json.Decode as Json exposing ((:=))
import Task exposing (..)
import Effects exposing (Effects, Never)


-- APP


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



-- MODEL


type alias Model =
    { stats : Stats
    , searchText : String
    }


type alias Stats =
    List StatsItem


type alias StatsItem =
    { feature : String
    , enabled : Int
    , total : Int
    }


model : Model
model =
    { stats = []
    , searchText = "work"
    }


appendRight : String -> String -> String
appendRight str1 str2 =
    str2 ++ str1


countPercentage : StatsItem -> Float
countPercentage statsItem =
    let
        floorToHundredth value =
            value
                |> (*) 100
                |> floor
                |> toFloat
                |> (flip (/)) 100
    in
        (toFloat statsItem.enabled)
            / (toFloat statsItem.total)
            |> (*) 100
            |> floorToHundredth


searchStats : Stats -> String -> Stats
searchStats stats searchText =
    let
        containsText statItem =
            String.contains searchText statItem.feature
    in
        stats
            |> List.filter containsText



-- VIEW


view : Address Action -> Model -> Html.Html
view address model =
    let
        filteredStats =
            searchStats model.stats model.searchText
    in
        div
            []
            [ statsTable filteredStats
            ]


statsTable : Stats -> Html.Html
statsTable stats =
    table
        []
        [ tbody [] (List.map statsTableRow stats)
        ]


statsTableRow : StatsItem -> Html.Html
statsTableRow statsItem =
    tr
        []
        [ td
            []
            [ text statsItem.feature ]
        , td
            []
            [ percentageText (countPercentage statsItem) ]
        ]


percentageText : Float -> Html.Html
percentageText percentage =
    percentage
        |> toString
        |> appendRight "%"
        |> text



-- UPDATE


type Action
    = ReplaceStats (Maybe Stats)


update : Action -> Model -> ( Model, Effects Action )
update action model =
    case action of
        ReplaceStats stats ->
            ( { model | stats = (Maybe.withDefault model.stats stats) }, Effects.none )



-- EFFECTS


fetchStats : Effects Action
fetchStats =
    Http.get statsDecoder "/stats"
        |> Task.toMaybe
        |> Task.map ReplaceStats
        |> Effects.task


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
