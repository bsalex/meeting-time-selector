module Participant exposing (..)

import CitySelector
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import App.NumberInput


type alias Model =
    { goodHours : List Int
    , isManual : Bool
    , city : CitySelector.Model
    , numberInput : App.NumberInput.Model
    }


type Msg
    = ToggleManual
    | CityMsg CitySelector.Msg
    | NumberInputMsg App.NumberInput.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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

                        inputModel =
                            model.numberInput

                        updatedInputModel =
                            { inputModel | value = toFloat shift }
                    in
                        { model | city = updatedModel, numberInput = updatedInputModel } ! [ Cmd.map CityMsg updateCmd ]

                _ ->
                    let
                        ( updatedModel, updateCmd ) =
                            CitySelector.update subMsg model.city
                    in
                        { model | city = updatedModel } ! [ Cmd.map CityMsg updateCmd ]


getInput : Model -> Html Msg
getInput model =
    if model.isManual then
        Html.map NumberInputMsg (App.NumberInput.view model.numberInput { step = 1, min = -12, max = 14 })
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
            , text "Set timezone manually"
            ]
        , getInput model
        ]


init : Model
init =
    Model (List.range 9 17) False CitySelector.init App.NumberInput.init


subsctiption : Model -> Sub Msg
subsctiption model =
    Sub.batch [ Sub.map NumberInputMsg <| App.NumberInput.subscription model.numberInput
              , Sub.map CityMsg <| CitySelector.subscriptions model.city
              ]
