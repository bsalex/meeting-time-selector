module App exposing (Model, Msg, update, view, subscriptions, init)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Header
import Participant
import MeetingIndicator
import MeetingTimeSelector
import Timeline
import Array exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { participants : Array Participant.Model
    , startTime : Float
    , duration : Float
    }


type Msg
    = StartTimeChanged Float
    | DurationChanged Float
    | AddParticipant
    | ParticipantMsg Participant.Msg Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartTimeChanged startTime ->
            ( { model | startTime = startTime }, Cmd.none )

        DurationChanged duration ->
            ( { model | duration = duration }, Cmd.none )

        AddParticipant ->
            ( { model | participants = Array.push ({ timeZone = 0 }) model.participants }, Cmd.none )

        ParticipantMsg subMsg index ->
            case subMsg of
                Participant.Remove ->
                    ( { model | participants = Array.append (Array.slice 0 index model.participants) (Array.slice (index + 1) (Array.length model.participants) model.participants) }, Cmd.none )

                _ ->
                    let
                        ( updatedParticipant, _ ) =
                            Participant.update subMsg (Maybe.withDefault { timeZone = 0 } (Array.get index model.participants))
                    in
                        ( { model | participants = Array.set index updatedParticipant model.participants }
                        , Cmd.none
                        )


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ Header.view
        , div [ class "app__participants" ]
            ((button
                [ class "app__add-participant"
                , onClick AddParticipant
                ]
                [ text "Add participant" ]
             )
                :: (Array.indexedMap (\index participant -> (Participant.view participant |> Html.map (\msg -> ParticipantMsg msg index))) model.participants |> Array.toList)
            )
        , div [ class "app__timelines" ]
            ((MeetingIndicator.view model.startTime model.duration) :: (Array.map (\participant -> Timeline.view participant.timeZone) model.participants |> Array.toList))
        , MeetingTimeSelector.view model.startTime (\value -> StartTimeChanged value) model.duration (\value -> DurationChanged value)
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : ( Model, Cmd Msg )
init =
    ( Model (Array.fromList [ { timeZone = 1 }, { timeZone = 2 }, { timeZone = 3 } ]) 10.0 0.5, Cmd.none )
