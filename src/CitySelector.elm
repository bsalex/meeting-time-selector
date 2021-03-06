module CitySelector exposing (..)

import Autocomplete
import Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Task
import Debounce
import TeleportCitiesSuggestions exposing (Suggestion)
import TeleportCityTimeZoneResolver exposing (..)


type alias Model =
    { places : List Place
    , autoState : Autocomplete.State
    , howManyToShow : Int
    , query : String
    , selectedPlace : Maybe Place
    , showMenu : Bool
    , d : Debounce.State
    , timezone : Int
    }


type alias Place =
    { description : String
    , placeId : String
    }


init : Model
init =
    { places = []
    , autoState = Autocomplete.empty
    , howManyToShow = 5
    , query = ""
    , selectedPlace = Nothing
    , showMenu = False
    , d = Debounce.init
    , timezone = 0
    }


type Msg
    = SetQuery String
    | SetAutoState Autocomplete.Msg
    | Wrap Bool
    | Reset
    | HandleEscape
    | SelectPlaceKeyboard String
    | SelectPlaceMouse String
    | PreviewPlace String
    | GotSuggestions (List TeleportCitiesSuggestions.Suggestion)
    | OnFocus
    | Deb (Debounce.Msg Msg)
    | GetSuggestions
    | GotTimezone Int
    | NoOp


getSuggestions : String -> Cmd Msg
getSuggestions query =
    TeleportCitiesSuggestions.suggest GotSuggestions query


getTimezone : String -> Cmd Msg
getTimezone query =
    TeleportCityTimeZoneResolver.resolveTimeZone GotTimezone query


debCmd : Msg -> Cmd Msg
debCmd =
    Debounce.debounceCmd cfg


cfg : Debounce.Config Model Msg
cfg =
    Debounce.config
        .d
        (\model s -> { model | d = s })
        Deb
        500


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetQuery newQuery ->
            let
                showMenu =
                    not << List.isEmpty <| (acceptablePlaces newQuery model.places)
            in
                { model | query = newQuery, showMenu = True, selectedPlace = Nothing }
                    ! [ debCmd <| GetSuggestions ]

        GetSuggestions ->
            model ! [ getSuggestions model.query ]

        Deb a ->
            Debounce.update cfg a model

        GotSuggestions suggestions ->
            ( { model | places = List.map (\suggestion -> Place suggestion.name suggestion.id) suggestions }, Cmd.none )

        GotTimezone shift ->
            ( { model | timezone = shift }, Cmd.none )

        SetAutoState autoMsg ->
            let
                ( newState, maybeMsg ) =
                    Autocomplete.update updateConfig autoMsg model.howManyToShow model.autoState (acceptablePlaces model.query model.places)

                newModel =
                    Debug.log "SetAutoState" { model | autoState = newState }
            in
                case maybeMsg of
                    Nothing ->
                        newModel ! []

                    Just updateMsg ->
                        update updateMsg newModel

        HandleEscape ->
            let
                validOptions =
                    not <| List.isEmpty (acceptablePlaces model.query model.places)

                handleEscape =
                    if validOptions then
                        model
                            |> removeSelection
                            |> resetMenu
                    else
                        model
                            |> resetInput

                escapedModel =
                    case model.selectedPlace of
                        Just place ->
                            if model.query == place.description then
                                model
                                    |> resetInput
                            else
                                handleEscape

                        Nothing ->
                            handleEscape
            in
                escapedModel ! []

        Wrap toTop ->
            case model.selectedPlace of
                Just place ->
                    update Reset model

                Nothing ->
                    if toTop then
                        { model
                            | autoState = Autocomplete.resetToLastItem updateConfig (acceptablePlaces model.query model.places) model.howManyToShow model.autoState
                            , selectedPlace = List.head <| List.reverse <| List.take model.howManyToShow <| (acceptablePlaces model.query model.places)
                        }
                            ! []
                    else
                        { model
                            | autoState = Autocomplete.resetToFirstItem updateConfig (acceptablePlaces model.query model.places) model.howManyToShow model.autoState
                            , selectedPlace = List.head <| List.take model.howManyToShow <| (acceptablePlaces model.query model.places)
                        }
                            ! []

        Reset ->
            { model | autoState = Autocomplete.reset updateConfig model.autoState, selectedPlace = Nothing } ! []

        SelectPlaceKeyboard id ->
            let
                newModel =
                    setQuery model id
                        |> resetMenu
            in
                newModel ! [ getTimezone id ]

        SelectPlaceMouse id ->
            let
                newModel =
                    setQuery model id
                        |> resetMenu
            in
                newModel ! [ Task.attempt (\_ -> NoOp) (Dom.focus "city-input"), getTimezone id ]

        PreviewPlace id ->
            { model | selectedPlace = Just <| getPlaceAtId model.places id } ! []

        OnFocus ->
            model ! []

        NoOp ->
            model ! []


resetInput : Model -> Model
resetInput model =
    { model | query = "" }
        |> removeSelection
        |> resetMenu


removeSelection : Model -> Model
removeSelection model =
    { model | selectedPlace = Nothing }


getPlaceAtId : List Place -> String -> Place
getPlaceAtId places id =
    List.filter (\place -> place.placeId == id) places
        |> List.head
        |> Maybe.withDefault (Place "Not Found" "")


setQuery : Model -> String -> Model
setQuery model id =
    { model
        | query = .description <| getPlaceAtId model.places id
        , selectedPlace = Just <| getPlaceAtId model.places id
    }


resetMenu : Model -> Model
resetMenu model =
    { model
        | autoState = Autocomplete.empty
        , showMenu = False
    }


view : Model -> Html Msg
view model =
    let
        options =
            { preventDefault = True, stopPropagation = False }

        dec =
            (Decode.map
                (\code ->
                    if code == 38 || code == 40 then
                        Ok NoOp
                    else if code == 27 then
                        Ok HandleEscape
                    else
                        Err "not handling that key"
                )
                keyCode
            )
                |> Decode.andThen
                    fromResult

        fromResult : Result String a -> Decode.Decoder a
        fromResult result =
            case result of
                Ok val ->
                    Decode.succeed val

                Err reason ->
                    Decode.fail reason

        menu =
            if model.showMenu then
                [ viewMenu model ]
            else
                []

        query =
            case model.selectedPlace of
                Just place ->
                    place.description

                Nothing ->
                    model.query
    in
        div [ class "city-selector" ]
            (List.append
                [ input
                    [ onInput SetQuery
                    , onFocus OnFocus
                    , onWithOptions "keydown" options dec
                    , value query
                    , id "city-input"
                    , class "autocomplete-input"
                    , autocomplete False
                    ]
                    []
                ]
                menu
            )


acceptablePlaces : String -> List Place -> List Place
acceptablePlaces query places =
    places


viewMenu : Model -> Html Msg
viewMenu model =
    div [ class "autocomplete-menu" ]
        [ Html.map SetAutoState (Autocomplete.view viewConfig model.howManyToShow model.autoState (acceptablePlaces model.query model.places)) ]


updateConfig : Autocomplete.UpdateConfig Msg Place
updateConfig =
    Autocomplete.updateConfig
        { toId = .placeId
        , onKeyDown =
            \code maybeId ->
                if Debug.log "code" code == 38 || code == 40 then
                    Maybe.map PreviewPlace maybeId
                else if code == 13 then
                    Maybe.map SelectPlaceKeyboard maybeId
                else
                    Just <| Reset
        , onTooLow = Just <| Wrap False
        , onTooHigh = Just <| Wrap True
        , onMouseEnter = \id -> Just <| PreviewPlace id
        , onMouseLeave = \_ -> Nothing
        , onMouseClick = \id -> Just <| SelectPlaceMouse id
        , separateSelections = False
        }


viewConfig : Autocomplete.ViewConfig Place
viewConfig =
    let
        customizedLi keySelected mouseSelected place =
            { attributes =
                [ classList [ ( "autocomplete-item", True ), ( "key-selected", keySelected || mouseSelected ) ]
                , id place.placeId
                ]
            , children = [ Html.text place.description ]
            }
    in
        Autocomplete.viewConfig
            { toId = .placeId
            , ul = [ class "autocomplete-list" ]
            , li = customizedLi
            }

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map SetAutoState Autocomplete.subscription
