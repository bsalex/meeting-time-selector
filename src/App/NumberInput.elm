module App.NumberInput exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Task
import Time


type Msg
    = StartRepeat Msg
    | EndRepeat


type alias Model =
    { inputSub : Sub Msg }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartRepeat msg ->
            let
                ( updatedModel, _ ) =
                    update msg model
            in
                { updatedModel | inputSub = (Time.every (Time.millisecond * 200) (\_ -> msg)) model.inputSub } ! []

        EndRepeat ->
            { model | inputSub = Sub.none } ! []


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

getOnInc : number -> number -> (number -> msg) -> msg
getOnInc value step onChange =
    onChange (value + step)

getOnDec : number -> number -> (number -> msg) -> msg
getOnDec value step onChange =
    onChange (value - step)

view : number -> number -> (number -> msg) -> Html msg
view currentValue step onChange =
    let
        onInc =
            getOnInc currentValue step onChange

        onDec =
            getOnDec currentValue step onChange
    in


    span []
        [ input [ value (toString currentValue), type_ "number"
                , on "wheel" (wheelEventToMessage onInc onDec)
                ] []
        , button
            [ onMouseDown (StartRepeat onInc)
            , onMouseUp (EndRepeat)
            ]
            [ text "+" ]
        , button
            [ onMouseDown (StartRepeat onDec)
            , onMouseUp (EndRepeat)
            ]
            [ text "-" ]
        ]


init : ( Model, Cmd Msg )
init =
    { inputSub = Sub.none } ! []


subscription : Model -> Sub Msg
subscription model = model.inputSub
