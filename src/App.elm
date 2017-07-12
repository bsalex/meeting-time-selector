port module App exposing (Model, Msg, update, view, subscriptions, init)

import Array exposing (..)
import Header
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import MeetingIndicator
import MeetingTimeSelector
import Participant
import ParticipantTimeline


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
    , meetingTimeSelector : MeetingTimeSelector.Model
    }


type Msg
    = AddParticipant
    | ParticipantMsg Int Participant.Msg
    | MeetingTimeSelectorMsg MeetingTimeSelector.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddParticipant ->
            { model | participants = Array.push Participant.init model.participants } ! []

        ParticipantMsg index subMsg ->
            case subMsg of
                Participant.Remove ->
                    { model | participants = Array.append (Array.slice 0 index model.participants) (Array.slice (index + 1) (Array.length model.participants) model.participants) } ! []

                _ ->
                    let
                        ( updatedParticipant, updateCmd ) =
                            Participant.update subMsg (Maybe.withDefault Participant.init (Array.get index model.participants))
                    in
                        ( { model | participants = Array.set index updatedParticipant model.participants }
                        , Cmd.map (ParticipantMsg index) updateCmd
                        )

        MeetingTimeSelectorMsg subMsg ->
            let
                ( updatedModel, updateCmd ) =
                    MeetingTimeSelector.update subMsg model.meetingTimeSelector
            in
                ( { model | meetingTimeSelector = updatedModel }
                , Cmd.map MeetingTimeSelectorMsg updateCmd
                )


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ Header.view [ class "app__header app__component" ]
        , div [ class "app__participants app__component" ]
            ((button
                [ class "app__add-participant"
                , onClick AddParticipant
                ]
                [ text "Add participant" ]
             )
                :: (Array.toList <| Array.indexedMap (\index participant -> Html.map (ParticipantMsg index) <| Participant.view participant) model.participants)
            )
        , div [ class "app__timelines app__component" ]
            ([ MeetingIndicator.view model.meetingTimeSelector.startTime model.meetingTimeSelector.duration ]
                ++ (Array.toList <| Array.map (ParticipantTimeline.view model.meetingTimeSelector.startTime model.meetingTimeSelector.duration) model.participants)
            )
        , Html.map MeetingTimeSelectorMsg (MeetingTimeSelector.view [ class "app__meeting app__component" ] model.meetingTimeSelector)
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.batch
            (Array.indexedMap
                (\index p -> Sub.map (ParticipantMsg index) (Participant.subsctiption p))
                model.participants
                |> Array.toList
            )
        , Sub.map MeetingTimeSelectorMsg (MeetingTimeSelector.subsctiption model.meetingTimeSelector)
        ]


init : ( Model, Cmd Msg )
init =
    ( Model (Array.fromList [ Participant.init, Participant.init, Participant.init ]) MeetingTimeSelector.init, Cmd.none )
