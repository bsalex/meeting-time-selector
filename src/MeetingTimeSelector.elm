module MeetingTimeSelector exposing (..)

import Html exposing (..)
import App.NumberInput


type alias Model =
    { startTimeInput : App.NumberInput.Model Msg
    , durationInput : App.NumberInput.Model Msg
    , startTime : Float
    , duration : Float
    }


type Msg
    = StartTimeNumberInputMsg (App.NumberInput.Msg Msg)
    | DurationNumberInputMsg (App.NumberInput.Msg Msg)
    | ShiftStartTime Float
    | ShiftDuration Float


view : List (Html.Attribute Msg) -> Model -> Html Msg
view attributes model =
    div ([] ++ attributes)
        [ span [] [ text "Start time (UTC +0)" ]
        , Html.map StartTimeNumberInputMsg <| App.NumberInput.view model.startTimeInput model.startTime 0.25 ShiftStartTime
        , span [] [ text "Duration" ]
        , Html.map DurationNumberInputMsg <| App.NumberInput.view model.durationInput model.duration 0.25 ShiftDuration
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShiftStartTime shift ->
            { model | startTime = model.startTime + shift } ! []

        ShiftDuration shift ->
            { model | duration = model.duration + shift } ! []

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
    Sub.batch [ model.startTimeInput.inputSub, model.durationInput.inputSub ]


init : Model
init =
    Model App.NumberInput.init App.NumberInput.init 17 1
