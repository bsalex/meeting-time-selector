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
        (Http.get (getSuggestionsUrl query) decodeSuggestions)


getSuggestionsUrl : String -> String
getSuggestionsUrl query =
    "https://api.teleport.org/api/cities/?search=" ++ query


decodeSuggestions : Decode.Decoder (List Suggestion)
decodeSuggestions =
    Decode.at [ "_embedded", "city:search-results" ]
        (Decode.list
            (Decode.map2
                Suggestion
                (Decode.at [ "_links", "city:item" ] (Decode.field "href" ( Decode.map extractCityIdFromUrl Decode.string )))
                (Decode.field "matching_full_name" Decode.string)
            )
        )


extractCityIdFromUrl : String -> String
extractCityIdFromUrl url =
    let
        startPosition =
            (+) (String.length "geonameid:") <| Maybe.withDefault 0 <| List.head <| String.indexes "geonameid:" url

        endPosition =
            Maybe.withDefault 0 <| List.head <| List.reverse <| String.indexes "/" url
    in
        String.slice startPosition endPosition url



{-
   {
     "_embedded": {
       "city:search-results": [
         {
           "_links": {
             "city:item": {
               "href": "https://api.teleport.org/api/cities/geonameid:703448/"
             }
           },
           "matching_alternate_names": [
             {
               "name": "Kieu"
             },
             {
               "name": "Kievi"
             },
             {
               "name": "Kiebo"
             },
             {
               "name": "Kief"
             },
             {
               "name": "kiefu"
             },
             {
               "name": "Kiev"
             },
             {
               "name": "Kievo"
             },
             {
               "name": "Kiev osh"
             },
             {
               "name": "Kiew"
             }
           ],
           "matching_full_name": "Kiev, Kyiv City, Ukraine"
         },
         {
           "_links": {
             "city:item": {
               "href": "https://api.teleport.org/api/cities/geonameid:2891122/"
             }
           },
           "matching_alternate_names": [
             {
               "name": "Kiel"
             },
             {
               "name": "Kielia"
             },
             {
               "name": "Kielo"
             }
           ],
           "matching_full_name": "Kiel, Schleswig-Holstein, Germany"
         }
       ]
     },
     "_links": {
       "curies": [
         {
           "href": "https://developers.teleport.org/api/resources/Location/#!/relations/{rel}/",
           "name": "location",
           "templated": true
         },
         {
           "href": "https://developers.teleport.org/api/resources/City/#!/relations/{rel}/",
           "name": "city",
           "templated": true
         },
         {
           "href": "https://developers.teleport.org/api/resources/UrbanArea/#!/relations/{rel}/",
           "name": "ua",
           "templated": true
         },
         {
           "href": "https://developers.teleport.org/api/resources/Country/#!/relations/{rel}/",
           "name": "country",
           "templated": true
         },
         {
           "href": "https://developers.teleport.org/api/resources/Admin1Division/#!/relations/{rel}/",
           "name": "a1",
           "templated": true
         },
         {
           "href": "https://developers.teleport.org/api/resources/Timezone/#!/relations/{rel}/",
           "name": "tz",
           "templated": true
         }
       ],
       "self": {
         "href": "https://api.teleport.org/api/cities/?search=Kie&geohash="
       }
     },
     "count": 2
   }

-}
