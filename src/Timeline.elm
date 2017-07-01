module Timeline exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import ListRotate

goodHours : List Int
goodHours = List.range 9 18

view : Int -> Html msg
view shift =
    div [ class "timeline" ] 
        (List.map ( \number -> div [ classList [ ("timeline__item", True) 
                                               , ("timeline__item--good", List.member number goodHours)
                                               , ("timeline__item--bad", not (List.member number goodHours))
                                               ] ] [ text (toString number) ] ) ( List.range 0 23 |> ListRotate.rotate shift ))