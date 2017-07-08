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


update : Msg msg -> Model msg -> ( Model msg, Cmd (Msg msg) )
update msg model =
    case msg of
        StartRepeat payloadMsg ->
            { model | inputSub = (Time.every (Time.millisecond * 200) (\_ -> payloadMsg)) } ! []

        EndRepeat ->
            { model | inputSub = Sub.none } ! []

        Do payloadMsg ->
            model ! [ Task.perform (\_ -> msg) (Task.succeed ()) ]


wheelEventToMessage : msg -> msg -> Json.Decoder (Msg msg)
wheelEventToMessage onInc onDec =
    Json.map
        (\delta ->
            if delta > 0 then
                Do onDec
            else
                Do onInc
        )
        (Json.field "deltaY" Json.int)

view : number -> number -> (number -> msg) -> Html (Msg msg)
view currentValue step onChange =
    let
        onInc =
            onChange (currentValue + step)

        onDec =
            onChange (currentValue - step)
    in
        span []
            [ input
                [ value (toString currentValue)
                , type_ "number"
                , on "wheel" (wheelEventToMessage onInc onDec)
                ]
                []
            , button
                [ onMouseDown (StartRepeat onInc)
                , onMouseUp EndRepeat
                ]
                [ text "+" ]
            , button
                [ onMouseDown (StartRepeat onDec)
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
