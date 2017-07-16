module MeetingTimeSelector exposing (..)

import Html exposing (..)
import App.NumberInput


type alias Model =
    { startTimeInput : App.NumberInput.Model
    , durationInput : App.NumberInput.Model
    }


type Msg
    = StartTimeNumberInputMsg App.NumberInput.Msg
    | DurationNumberInputMsg App.NumberInput.Msg


view : List (Html.Attribute Msg) -> Model -> Html Msg
view attributes model =
    div ([] ++ attributes)
        [ span [] [ text "Start time (UTC +0)" ]
        , Html.map StartTimeNumberInputMsg <| App.NumberInput.view model.startTimeInput { step = 0.25, min = 0, max = 24 - model.durationInput.value }
        , span [] [ text "Duration" ]
        , Html.map DurationNumberInputMsg <| App.NumberInput.view model.durationInput { step = 0.25, min = 0, max = 24 - model.startTimeInput.value }
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartTimeNumberInputMsg subMsg ->
            let
                ( updatedModel, updateCmd ) =
                    App.NumberInput.update subMsg model.startTimeInput
            in
                { model | startTimeInput = updatedModel } ! [ updateCmd ]

        DurationNumberInputMsg subMsg ->
            let
                ( updatedModel, updateCmd ) =
                    App.NumberInput.update subMsg model.durationInput
            in
                { model | durationInput = updatedModel } ! [ updateCmd ]


subsctiption : Model -> Sub Msg
subsctiption model =
    Sub.batch [ Sub.map StartTimeNumberInputMsg (App.NumberInput.subscription model.startTimeInput), Sub.map DurationNumberInputMsg (App.NumberInput.subscription model.durationInput) ]


init : Model
init =
    Model App.NumberInput.init App.NumberInput.init
