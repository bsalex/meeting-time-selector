module App exposing (Model, Msg, update, view, subscriptions, init)

import Array exposing (..)
import CitySelector
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
    , startTime : Float
    , duration : Float
    , city : CitySelector.Model
    }


type Msg
    = StartTimeChanged Float
    | DurationChanged Float
    | AddParticipant
    | CitySelected CitySelector.Msg
    | ParticipantMsg Participant.Msg Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartTimeChanged startTime ->
            ( { model | startTime = startTime }, Cmd.none )

        DurationChanged duration ->
            ( { model | duration = duration }, Cmd.none )

        AddParticipant ->
            ( { model | participants = Array.push Participant.init model.participants }, Cmd.none )

        ParticipantMsg subMsg index ->
            case subMsg of
                Participant.Remove ->
                    ( { model | participants = Array.append (Array.slice 0 index model.participants) (Array.slice (index + 1) (Array.length model.participants) model.participants) }, Cmd.none )

                _ ->
                    let
                        ( updatedParticipant, _ ) =
                            Participant.update subMsg (Maybe.withDefault Participant.init (Array.get index model.participants))
                    in
                        ( { model | participants = Array.set index updatedParticipant model.participants }
                        , Cmd.none
                        )
        CitySelected subMsg ->
            let
                ( updateModel, updateCmd ) = CitySelector.update subMsg model.city
            in
                ( { model | city = updateModel }, Cmd.map CitySelected updateCmd )

view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ Header.view
        , Html.map CitySelected (CitySelector.view model.city)
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
            ((MeetingIndicator.view model.startTime model.duration) :: (Array.map (\participant -> ParticipantTimeline.view participant model.startTime model.duration ) model.participants |> Array.toList))
        , MeetingTimeSelector.view model.startTime (\value -> StartTimeChanged value) model.duration (\value -> DurationChanged value)
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

type alias Flags = {
    token: String
}

init : ( Model, Cmd Msg )
init =
    ( Model (Array.fromList [ Participant.init, Participant.init, Participant.init ]) 17.75 0.5 CitySelector.init, Cmd.none )
