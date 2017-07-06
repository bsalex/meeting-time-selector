module MeetingTimeSelector exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


view : List (Html.Attribute msg) -> Float -> (Float -> msg) -> Float -> (Float -> msg) -> Html msg
view attributes start onStartChanged duration onDurationChanged =
    div ([] ++ attributes)
        [ span [] [ text "Start time" ]
        , input
            [ type_ "number"
            , step "0.25"
            , value (toString start)
            , onInput (\value -> onStartChanged (Result.withDefault 0 (String.toFloat value)))
            ]
            []
        , span [] [ text "Duration" ]
        , input
            [ type_ "number"
            , step "0.25"
            , value (toString duration)
            , onInput (\value -> onDurationChanged (Result.withDefault 0 (String.toFloat value)))
            ]
            []
        ]
