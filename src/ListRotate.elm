module ListRotate exposing (..)


rotate : Int -> List a -> List a
rotate shift list =
    let
        normalizedshift =
            (abs shift) % List.length list
    in
        if shift >= 0 then
            List.concat [ List.drop normalizedshift list, List.take normalizedshift list ]
        else
            List.concat [ List.drop (List.length list - normalizedshift) list, List.take (List.length list - normalizedshift) list ]
