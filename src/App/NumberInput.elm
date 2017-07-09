module App.NumberInput exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Task
import Time


type Msg msg = EndRepeat | Do msg | StartRepeat msg


type alias Model msg =
    { inputSub : Sub msg }


update : Msg msg -> Model msg -> ( Model msg, Cmd msg )
update msg model =
    case msg of
        StartRepeat payloadMsg ->
            let
                (updatedModel, updateCmd) = update (Do payloadMsg) model
            in
                { updatedModel | inputSub = (Time.every (Time.millisecond * 200) (\_ -> Debug.log "payload" payloadMsg)) } ! [ updateCmd ]

        EndRepeat ->
            { model | inputSub = Sub.none } ! []

        Do payloadMsg ->
            model ! [ Task.perform identity (Task.succeed payloadMsg) ]


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

view : Float -> Float -> (Float -> msg) -> (Float -> msg) -> Html (Msg msg)
view currentValue step onChange onShift =
    let
        onInc =
            onChange (Debug.log "222" currentValue + step)

        onDec =
            onChange (currentValue - step)
    in
        span []
            [ input
                [ value (toString currentValue)
                , type_ "number"
                , on "wheel" (wheelEventToMessage (Do onInc) (Do onDec))
                , onInput (\s -> Do (onChange (Result.withDefault currentValue (String.toFloat s))))
                ]
                []
            , button
                [ onMouseDown (StartRepeat (onShift 1))
                , onMouseUp EndRepeat
                ]
                [ text "+" ]
            , button
                [ onMouseDown (StartRepeat (onShift -1))
                , onMouseUp EndRepeat
                ]
                [ text "-" ]
            ]


init : Model msg
init =
    { inputSub = Sub.none }


subscription : Model msg -> Sub msg
subscription model =
    model.inputSub
