module Update (Action(ReplaceStats, FilterFeatures), update) where

import Model exposing (Model, Stats)
import Effects exposing (Effects)


type Action
    = ReplaceStats (Maybe Stats)
    | FilterFeatures String


update : Action -> Model -> ( Model, Effects Action )
update action model =
    case action of
        ReplaceStats stats ->
            ( { model | stats = (Maybe.withDefault model.stats stats) }, Effects.none )

        FilterFeatures text ->
            ( { model | searchText = text }, Effects.none )
