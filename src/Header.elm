module Header exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

view : Html msg
view =
    div [ class "app__header" ]
        [ text "Time picker for meetings in different time zones"
        ]