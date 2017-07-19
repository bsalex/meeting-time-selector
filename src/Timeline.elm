module Timeline exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


view : Int -> List Int -> List (Html.Attribute msg) -> Html msg
view shift goodHours attributes =
    div ([ class "timeline" ] ++ attributes)
        [ div [ class "timeline__items", style [ ( "margin-left", toString (-100 - ((100 / 24) * toFloat shift)) ++ "%" ) ] ]
            (List.map
                (\number ->
                    div
                        [ classList
                            [ ( "timeline__item", True )
                            , ( "timeline__item--good", List.member number goodHours )
                            , ( "timeline__item--bad", not (List.member number goodHours) )
                            ]
                        ]
                        [ text (toString number) ]
                )
                (List.concat <| List.repeat 3 (List.range 0 23))
            )
        ]
