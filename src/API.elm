module API (..) where

import Http
import Json.Decode as Json exposing ((:=))
import Task
import Effects exposing (Effects)
import Update exposing (Action(ReplaceStats))
import Model exposing (Stats, StatsItem)


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
