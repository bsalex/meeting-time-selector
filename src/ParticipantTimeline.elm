module ParticipantTimeline exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Debug
import Timeline
import Participant


matchesGoodTime : Participant.Model -> Float -> Float -> Bool
matchesGoodTime participant startTime duration =
    let
        startGoodTime =
            List.minimum participant.goodHours
                |> Maybe.withDefault 0
                |> flip (-) participant.timeZone
                |> toFloat

        endGoodTime =
            List.maximum participant.goodHours
                |> Maybe.withDefault 24
                |> flip (-) participant.timeZone
                |> (+) 1
                |> toFloat

        startMeeging = startTime

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


view : Participant.Model -> Float -> Float -> Html msg
view participant startTime duration =
    Timeline.view participant.timeZone participant.goodHours [ class (timelineClass participant startTime duration) ]
