module TeleportCitiesSuggestions exposing (..)

import Http
import Json.Decode as Decode
import Result


type alias Suggestion =
    { id : String
    , name : String
    }


suggest : (List Suggestion -> msg) -> String -> Cmd msg
suggest resultToMessage query =
    Http.send
        (\result ->
            case result of
                Ok value ->
                    resultToMessage (Debug.log "values" value)

                Err _ ->
                    resultToMessage []
        )
    <|
        Http.get (getSuggestionsUrl query) decodeSuggestions


getSuggestionsUrl : String -> String
getSuggestionsUrl query =
    "https://api.teleport.org/api/cities/?search=" ++ query


decodeSuggestions : Decode.Decoder (List Suggestion)
decodeSuggestions =
    Decode.at [ "_embedded", "city:search-results" ] <|
        Decode.list <|
            Decode.map2
                Suggestion
                (Decode.at [ "_links", "city:item" ] <| Decode.field "href" <| Decode.map extractCityIdFromUrl Decode.string)
                (Decode.field "matching_full_name" Decode.string)


extractCityIdFromUrl : String -> String
extractCityIdFromUrl url =
    let
        startPosition =
            (+) (String.length "geonameid:") <| Maybe.withDefault 0 <| List.head <| String.indexes "geonameid:" url

        endPosition =
            Maybe.withDefault 0 <| List.head <| List.reverse <| String.indexes "/" url
    in
        String.slice startPosition endPosition url
