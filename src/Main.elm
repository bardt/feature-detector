module Main (..) where

import Html exposing (div, table, tbody, tr, td, text)
import StartApp.Simple as StartApp
import Signal exposing (Address)


main : Signal Html.Html
main =
    StartApp.start
        { model = model
        , view = view
        , update = update
        }


type alias StatsItem =
    { feature : String, percentage : Float }


type alias Stats =
    List StatsItem


type alias Model =
    { stats : Stats }


demoStats : List StatsItem
demoStats =
    [ { feature = "service workers"
      , percentage = 61.4
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


statsTableItem : StatsItem -> Html.Html
statsTableItem statsItem =
    tr
        []
        [ td
            []
            [ text statsItem.feature ]
        , td
            []
            [ percentageText statsItem.percentage ]
        ]


statsTable : Stats -> Html.Html
statsTable stats =
    table
        []
        [ tbody [] (List.map statsTableItem stats)
        ]


type Action
    = Action


view : Address Action -> Model -> Html.Html
view address model =
    div
        []
        [ statsTable model.stats
        ]


update : Action -> Model -> Model
update _ model =
    model
