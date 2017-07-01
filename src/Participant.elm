module Participant exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Model =
    { timeZone : Int
    }

model : Model
model =
    { timeZone = 0
    }

type Msg
    = ChangeTimeZone String
    | Remove

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Remove -> ( model, Cmd.none )
        ChangeTimeZone newTimeZone -> ( { model | timeZone = (Result.withDefault 0 (String.toInt newTimeZone)) }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "app__participant participant" ] 
        [ input [ value (toString model.timeZone)
                , class "participant__timezone"
                , type_ "number"
                , onInput ChangeTimeZone
                ] []
        , button [ class "participant__remove", onClick Remove ] [ text "🗙" ]
        ]