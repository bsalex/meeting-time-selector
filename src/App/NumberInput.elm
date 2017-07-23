module App.NumberInput exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json exposing (decodeValue)
import Time


type Msg
    = EndRepeat
    | StartRepeat (Float -> Msg)
    | ChangeValue Float Float Float (Float -> Float -> Float) Float
    | SetOverrideValue String


type alias Model =
    { inputSub : Maybe (Float -> Msg)
    , overrideValue : Maybe String
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

        ChangeValue min max step operator currentValue ->
            let
                shouldProceed =
                    isOperationAvailable min max step currentValue operator
            in
                if shouldProceed then
                    { model | value = operator currentValue step, overrideValue = Maybe.Nothing } ! []
                else
                    { model | inputSub = Maybe.Nothing, overrideValue = Maybe.Nothing } ! []

        SetOverrideValue value ->
            { model | overrideValue = Maybe.Just value } ! []


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


isOperationAvailable : Float -> Float -> Float -> Float -> (Float -> Float -> Float) -> Bool
isOperationAvailable min max step currentValue operation =
    let
        updatedValue =
            operation currentValue step
    in
        min <= updatedValue && updatedValue <= max


identityOfFirstArgument : a -> a -> a
identityOfFirstArgument firstArgument _ =
    firstArgument


inputChangeToMsg : (Float -> Float -> Msg) -> Float -> String -> Msg
inputChangeToMsg onShift currentValue stringValue =
    case stringValue of
        "-" ->
            SetOverrideValue stringValue

        "+" ->
            SetOverrideValue stringValue

        "" ->
            onShift currentValue -currentValue

        "0-" ->
            SetOverrideValue "-"

        "0+" ->
            SetOverrideValue "+"

        _ ->
            let
                parsedFloatValue =
                    String.toFloat stringValue
            in
                case parsedFloatValue of
                    Result.Ok value ->
                        if String.endsWith "." stringValue then
                            SetOverrideValue stringValue
                        else
                            onShift currentValue <| value - currentValue

                    Result.Err _ ->
                        onShift currentValue 0


view : Model -> Options -> Html Msg
view model options =
    let
        currentValue =
            model.value

        incAvailable =
            isOperationAvailable options.min options.max options.step currentValue (+)

        decAvailable =
            isOperationAvailable options.min options.max options.step currentValue (-)

        onInc =
            if incAvailable then
                ChangeValue options.min options.max options.step (+) model.value
            else
                ChangeValue options.min options.max options.step identityOfFirstArgument model.value

        onDec =
            if decAvailable then
                ChangeValue options.min options.max options.step (-) model.value
            else
                ChangeValue options.min options.max options.step identityOfFirstArgument model.value
    in
        span []
            [ input
                [ value
                    (case model.overrideValue of
                        Just overrideValue ->
                            overrideValue

                        Nothing ->
                            toString currentValue
                    )
                , on "wheel" <| wheelEventToMessage onInc onDec
                , onWithOptions "keydown"
                    { preventDefault = True, stopPropagation = False }
                    (inputKeyCodeToMsg onInc onDec)
                , onInput <| inputChangeToMsg (\step -> ChangeValue options.min options.max step (+)) currentValue
                ]
                []
            , button
                [ onMouseDown (StartRepeat <| ChangeValue options.min options.max options.step (+))
                , onMouseUp EndRepeat
                , disabled <| not incAvailable
                ]
                [ text "+" ]
            , button
                [ onMouseDown (StartRepeat <| ChangeValue options.min options.max options.step (-))
                , onMouseUp EndRepeat
                , disabled <| not decAvailable
                ]
                [ text "-" ]
            ]


init : Model
init =
    { inputSub = Maybe.Nothing, overrideValue = Maybe.Nothing, value = 0 }


subscription : Model -> Sub Msg
subscription model =
    case model.inputSub of
        Maybe.Just payloadMsg ->
            Time.every (Time.millisecond * 200) (always <| payloadMsg model.value)

        Nothing ->
            Sub.none
