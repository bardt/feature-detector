module Model (..) where


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
    , searchText = ""
    }
