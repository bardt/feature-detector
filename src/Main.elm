module Main (..) where

import Html exposing (div, table, tbody, tr, td, text)
import StartApp.Simple as StartApp


main =
    StartApp.start
        { model = model
        , view = view
        , update = update
        }


demoStats =
    [ { feature = "service workers"
      , percentage = 61.4
      }
    ]


model =
    { stats = demoStats }


appendRight str1 str2 =
    str2 ++ str1


percentageText percentage =
    percentage
        |> toString
        |> appendRight "%"
        |> text


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


statsTable stats =
    table
        []
        [ tbody [] (List.map statsTableItem stats)
        ]


view address model =
    div
        []
        [ statsTable model.stats
        ]


update _ model =
    model
