module MeetingIndicator exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


view : Float -> Float -> Html msg
view start duration =
    let
        left =
            (100 / 24) * start

        width =
            (100 / 24) * duration
    in
        div [ class "meeting-indicator", style [ ( "left", toString left ++ "%" ), ( "width", toString width ++ "%" ) ] ] []
