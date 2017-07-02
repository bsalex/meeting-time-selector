module Participant exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Model =
    { timeZone : Int
    , goodHours : List Int
    }

type Msg
    = ChangeTimeZone String
    | Remove


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Remove ->
            ( model, Cmd.none )

        ChangeTimeZone newTimeZone ->
            ( { model | timeZone = (Result.withDefault 0 (String.toInt newTimeZone)) }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "app__participant participant" ]
        [ input
            [ value (toString model.timeZone)
            , class "participant__timezone"
            , type_ "number"
            , onInput ChangeTimeZone
            , Html.Attributes.max "12"
            , Html.Attributes.min "-12"
            ]
            []
        , button [ class "participant__remove", onClick Remove ] [ text "🗙" ]
        ]

init : Model
init = Model 0 (List.range 9 17)
