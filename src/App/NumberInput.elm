module App.NumberInput exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json exposing (decodeValue)
import Time


type Msg
    = EndRepeat
    | StartRepeat (Float -> Msg)
    | ShiftValue Float Options (Float -> Float -> Float)
    | SetOverrideValue String


type alias Model =
    { inputSub : Maybe (Float -> Msg)
    , overrideValue : String
    , value : Float
    }


type alias Options =
    { min : Float
    , max : Float
    , step : Float
    }


isPlusOperator : (number -> number -> number) -> Bool
isPlusOperator operator =
    operator 7 8 == 15


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        StartRepeat payloadMsg ->
            let
                ( updatedModel, updateCmd ) =
                    update (payloadMsg model.value) model
            in
                { updatedModel | inputSub = Maybe.Just payloadMsg } ! [ updateCmd ]

        EndRepeat ->
            { model | inputSub = Maybe.Nothing } ! []

        ShiftValue currentValue options operator ->
            let
                shouldProceed =
                    if isPlusOperator operator then
                        isIncAvailable currentValue options
                    else
                        isDecAvailable currentValue options
            in
                if shouldProceed then
                    { model | value = operator currentValue options.step } ! []
                else
                    { model | inputSub = Maybe.Nothing } ! []

        SetOverrideValue value ->
            { model | overrideValue = value } ! []


wheelEventToMessage : Msg -> Msg -> Json.Decoder Msg
wheelEventToMessage onInc onDec =
    Json.map
        (\delta ->
            if delta > 0 then
                onDec
            else
                onInc
        )
        (Json.field "deltaY" Json.int)


inputKeyCodeToMsg : Msg -> Msg -> Json.Decoder Msg
inputKeyCodeToMsg onInc onDec =
    ((Json.map
        (\code ->
            if code == 38 then
                Ok onInc
            else if code == 40 then
                Ok onDec
            else
                Err "not handling that key"
        )
        keyCode
     )
        |> Json.andThen
            (\result ->
                case result of
                    Ok val ->
                        Json.succeed val

                    Err reason ->
                        Json.fail reason
            )
    )


inputChangeToMsg : (Float -> Msg) -> Float -> String -> Msg
inputChangeToMsg onShift currentValue stringValue =
    if (stringValue == "-" || stringValue == "+") then
        SetOverrideValue stringValue
    else if stringValue == "0-" then
        SetOverrideValue "-"
    else if stringValue == "0+" then
        SetOverrideValue "+"
    else if stringValue == "" then
        onShift -currentValue
    else
        onShift <| (Result.withDefault currentValue (String.toFloat stringValue)) - currentValue


isIncAvailable : Float -> Options -> Bool
isIncAvailable currentValue options =
    currentValue + options.step <= options.max


isDecAvailable : Float -> Options -> Bool
isDecAvailable currentValue options =
    currentValue - options.step >= options.min


identityOfFirstArgument : a -> a -> a
identityOfFirstArgument firstArgument _ =
    firstArgument


view : Model -> Options -> Html Msg
view model options =
    let
        currentValue =
            model.value

        incAvailable =
            isIncAvailable currentValue options

        decAvailable =
            isDecAvailable currentValue options

        onInc =
            if incAvailable then
                ShiftValue model.value options (+)
            else
                ShiftValue model.value options identityOfFirstArgument

        onDec =
            if decAvailable then
                ShiftValue model.value options (-)
            else
                ShiftValue model.value options identityOfFirstArgument
    in
        span []
            [ input
                [ value
                    (if model.overrideValue /= "" then
                        model.overrideValue
                     else
                        (toString currentValue)
                    )
                , on "wheel" <| wheelEventToMessage onInc onDec
                , onWithOptions "keydown"
                    { preventDefault = True, stopPropagation = False }
                    (inputKeyCodeToMsg (onInc) (onDec))
                , onInput (inputChangeToMsg (\x -> ShiftValue x options (+)) currentValue)
                ]
                []
            , button
                [ onMouseDown (StartRepeat (\a -> ShiftValue a options (+)))
                , onMouseUp EndRepeat
                , disabled <| not incAvailable
                ]
                [ text "+" ]
            , button
                [ onMouseDown (StartRepeat (\a -> ShiftValue a options (-)))
                , onMouseUp EndRepeat
                , disabled <| not decAvailable
                ]
                [ text "-" ]
            ]


init : Model
init =
    { inputSub = Maybe.Nothing, overrideValue = "", value = 0 }


subscription : Model -> Sub Msg
subscription model =
    case model.inputSub of
        Maybe.Just payloadMsg ->
            Time.every (Time.millisecond * 200) (always <| payloadMsg model.value)

        Nothing ->
            Sub.none
