module TeleportCityTimeZoneResolver exposing (..)

import Http
import Json.Decode as Decode
import Result
import Task


type alias Suggestion =
    { id : String
    , name : String
    }


resolveTimeZone : (Int -> msg) -> String -> Cmd msg
resolveTimeZone resultToMessage query =
    Task.attempt
        (\result ->
            case result of
                Ok value ->
                    resultToMessage value

                Err _ ->
                    resultToMessage -100
        )
        (Http.toTask (Http.get (getCityDetailsUrl query) decodeCityTimeZoneName)
            |> Task.andThen (\tzName -> Http.toTask (Http.get (getTimezoneUrl tzName) decodeTimeZoneShift))
            |> Task.andThen (\shift -> (Task.succeed (shift // 60)))
        )


getCityDetailsUrl : String -> String
getCityDetailsUrl code =
    "https://api.teleport.org/api/cities/geonameid:" ++ code ++ "/"


getTimezoneUrl : String -> String
getTimezoneUrl name =
    "https://api.teleport.org/api/timezones/iana:" ++ (String.split "/" name |> String.join "%2F") ++ "/offsets/?date=2017-07-04T00:49:22Z"


decodeCityTimeZoneName : Decode.Decoder String
decodeCityTimeZoneName =
    Decode.at [ "_links", "city:timezone" ] (Decode.field "name" Decode.string)


decodeTimeZoneShift : Decode.Decoder Int
decodeTimeZoneShift =
    Decode.field "base_offset_min" Decode.int
