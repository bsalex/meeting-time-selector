module Participant exposing (..)

import CitySelector
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Model =
    { timeZone : Int
    , goodHours : List Int
    , isManual : Bool
    , city: CitySelector.Model
    }


type Msg
    = ChangeTimeZone String
    | Remove
    | ToggleManual
    | CityMsg CitySelector.Msg
    | GetPlaceCitySuggestions String
    | SetPlaceCitySuggestions (List CitySelector.Place)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Remove ->
            ( model, Cmd.none )

        ChangeTimeZone newTimeZone ->
            ( { model | timeZone = (Result.withDefault 0 (String.toInt newTimeZone)) }, Cmd.none )

        ToggleManual ->
            { model | isManual = not model.isManual } ! []

        GetPlaceCitySuggestions query ->
            ( Debug.log "city model" model, Cmd.none )

        SetPlaceCitySuggestions suggestions ->
            let
                city = model.city
                updatedCity = { city | places = suggestions }
            in
                { model | city = updatedCity } ! []

        CityMsg subMsg ->
            case subMsg of
                CitySelector.SetQuery query ->
                    let
                        ( updatedModel, updateCmd ) = CitySelector.update subMsg model.city
                    in
                        { model | city = updatedModel } ! []
                _ ->
                    let
                        ( updatedModel, updateCmd ) = CitySelector.update subMsg model.city
                    in
                        ( { model | city = updatedModel }, Cmd.map CityMsg updateCmd )


getInput : Model -> Html Msg
getInput model =
    if model.isManual then
        input
            [ value (toString model.timeZone)
            , class "participant__timezone"
            , type_ "number"
            , onInput ChangeTimeZone
            , Html.Attributes.max "12"
            , Html.Attributes.min "-12"
            ]
            []
    else
        Html.map CityMsg ( CitySelector.view model.city )


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
    Model 0 (List.range 9 17) False CitySelector.init
