module View (..) where

import String
import Html exposing (div, table, tbody, tr, td, text, input)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetValue)
import Signal exposing (Address)
import Model exposing (Model, Stats, StatsItem)
import Update exposing (Action(FilterFeatures))


view : Address Action -> Model -> Html.Html
view address model =
    let
        searchText = model.searchText

        filteredStats =
            searchStats model.stats searchText
    in
        div
            []
            [ searchBox address searchText
            , statsTable filteredStats
            ]


searchBox : Address Action -> String -> Html.Html
searchBox address text =
    let
        actionMessage value =
            value
                |> FilterFeatures
                |> Signal.message address
    in
        input
            [ placeholder "Search features..."
            , value text
            , on "input" targetValue actionMessage
            ]
            []


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


searchStats : Stats -> String -> Stats
searchStats stats searchText =
    let
        containsText statItem =
            String.contains searchText statItem.feature
    in
        stats
            |> List.filter containsText


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


percentageText : Float -> Html.Html
percentageText percentage =
    percentage
        |> toString
        |> (flip (++)) "%"
        |> text
