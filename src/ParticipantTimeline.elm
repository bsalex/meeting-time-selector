module ParticipantTimeline exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Timeline
import Participant


matchesGoodTime : Participant.Model -> Float -> Float -> Bool
matchesGoodTime participant startTime duration =
    let
        startGoodTime =
            List.minimum participant.goodHours
                |> Maybe.withDefault 0
                |> (flip (-) <| floor participant.numberInput.value)
                |> toFloat

        endGoodTime =
            List.maximum participant.goodHours
                |> Maybe.withDefault 24
                |> (flip (-) <| floor participant.numberInput.value)
                |> (+) 1
                |> toFloat

        startMeeging =
            startTime

        endMeeting =
            startTime + duration
    in
        startGoodTime <= startMeeging && endMeeting <= endGoodTime


timelineClass : Participant.Model -> Float -> Float -> String
timelineClass participant startTime duration =
    if matchesGoodTime participant startTime duration then
        "timeline--matches-meeting"
    else
        "timeline--not-matches-meeting"


view : Float -> Float -> Participant.Model -> Html msg
view startTime duration participant =
    Timeline.view (floor participant.numberInput.value) participant.goodHours [ class (timelineClass participant startTime duration) ]
