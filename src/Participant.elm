module Participant exposing (..)

import CitySelector
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import App.NumberInput


type alias Model =
    { timeZone : Int
    , goodHours : List Int
    , isManual : Bool
    , city : CitySelector.Model
    , numberInput : App.NumberInput.Model Msg
    }


type Msg
    = ShiftTimeZone Int
    | Remove
    | ToggleManual
    | CityMsg CitySelector.Msg
    | NumberInputMsg (App.NumberInput.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Remove ->
            model ! []

        ShiftTimeZone shift ->
            { model | timeZone = model.timeZone + shift } ! []

        ToggleManual ->
            { model | isManual = not model.isManual } ! []

        NumberInputMsg subMsg ->
            let
                ( updatedModel, updateCmd ) =
                    App.NumberInput.update subMsg model.numberInput
            in
                { model | numberInput = updatedModel } ! [ updateCmd ]

        CityMsg subMsg ->
            case subMsg of
                CitySelector.GotTimezone shift ->
                    let
                        ( updatedModel, updateCmd ) =
                            CitySelector.update subMsg model.city
                    in
                        { model | city = updatedModel, timeZone = shift } ! [ Cmd.map CityMsg updateCmd ]

                _ ->
                    let
                        ( updatedModel, updateCmd ) =
                            CitySelector.update subMsg model.city
                    in
                        { model | city = updatedModel } ! [ Cmd.map CityMsg updateCmd ]


getInput : Model -> Html Msg
getInput model =
    if model.isManual then
        Html.map NumberInputMsg (App.NumberInput.view model.numberInput (toFloat model.timeZone) {step = 1, min = -12, max = 14} (ShiftTimeZone << floor))
    else
        Html.map CityMsg (CitySelector.view model.city)


view : Model -> Html Msg
view model =
    div [ class "app__participant participant" ]
        [ label []
            [ input
                [ type_ "checkbox"
                , checked model.isManual
                , onClick ToggleManual
                ]
                []
            , text "Set timezone mannually"
            ]
        , getInput model
        , button [ class "participant__remove", onClick Remove ] [ text "🗙" ]
        ]


init : Model
init =
    Model 0 (List.range 9 17) False CitySelector.init App.NumberInput.init


subsctiption : Model -> Sub Msg
subsctiption model =
    model.numberInput.inputSub
