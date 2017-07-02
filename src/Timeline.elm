module Timeline exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import ListRotate


view : Int -> List Int -> List (Html.Attribute msg) -> Html msg
view shift goodHours attributes =
    div (List.concat [ [ class "timeline" ], attributes ])
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
            (List.range 0 23 |> ListRotate.rotate shift)
        )
