module App.NumberInput exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json exposing (decodeValue)
import Task
import Time


type Msg msg
    = EndRepeat
    | Do msg
    | StartRepeat msg
    | SetOverrideValue String


type alias Model msg =
    { inputSub : Sub msg
    , overrideValue : String
    }

type alias Options =
    { min : Float
    , max : Float
    , step : Float
    }

update : Msg msg -> Model msg -> ( Model msg, Cmd msg )
update msg model =
    case msg of
        StartRepeat payloadMsg ->
            let
                ( updatedModel, updateCmd ) =
                    update (Do payloadMsg) model
            in
                { updatedModel | inputSub = Time.every (Time.millisecond * 200) (always payloadMsg) } ! [ updateCmd ]

        EndRepeat ->
            { model | inputSub = Sub.none } ! []

        Do payloadMsg ->
            { model | overrideValue = "" } ! [ Task.perform identity (Task.succeed payloadMsg) ]

        SetOverrideValue value ->
            { model | overrideValue = value } ! []


wheelEventToMessage : msg -> msg -> Json.Decoder msg
wheelEventToMessage onInc onDec =
    Json.map
        (\delta ->
            if delta > 0 then
                onDec
            else
                onInc
        )
        (Json.field "deltaY" Json.int)


inputKeyCodeToMsg : msg -> msg -> Json.Decoder msg
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


inputChangeToMsg : (Float -> Msg msg) -> Float -> String -> Msg msg
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
        onShift ((Result.withDefault currentValue (String.toFloat stringValue)) - currentValue)


view : Model msg -> Float -> Options -> (Float -> msg) -> Html (Msg msg)
view model currentValue options onShift =
    let
        incAvailable = currentValue + options.step <= options.max
        decAvailable = currentValue - options.step >= options.min
        onInc =
            if incAvailable then onShift options.step else onShift 0

        onDec =
            if decAvailable then onShift -options.step else onShift 0
    in
        span []
            [ input
                [ value
                    (if model.overrideValue /= "" then
                        model.overrideValue
                     else
                        (toString currentValue)
                    )
                , on "wheel" (wheelEventToMessage (Do onInc) (Do onDec))
                , onWithOptions "keydown"
                    { preventDefault = True, stopPropagation = False }
                    (inputKeyCodeToMsg (Do onInc) (Do onDec))
                , onInput (inputChangeToMsg (\v -> Do (onShift v)) currentValue)
                ]
                []
            , button
                [ onMouseDown (StartRepeat onInc)
                , onMouseUp EndRepeat
                , disabled <| not incAvailable
                ]
                [ text "+" ]
            , button
                [ onMouseDown (StartRepeat onDec)
                , onMouseUp EndRepeat
                , disabled <| not decAvailable
                ]
                [ text "-" ]
            ]


init : Model msg
init =
    { inputSub = Sub.none, overrideValue = "" }


subscription : Model msg -> Sub msg
subscription model =
    model.inputSub
