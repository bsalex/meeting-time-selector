module Header exposing (..)

import Html exposing (..)


view : List (Html.Attribute msg) -> Html msg
view attributes =
    div (List.concat [ [ ], attributes ])
        [ h1 [] [ text "Time picker for meetings in different time zones" ]
        ]
