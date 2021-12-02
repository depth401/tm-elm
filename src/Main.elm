module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import List.Extra as List



-- MODEL


type alias Model =
    String


init : () -> ( Model, Cmd Msg )
init _ =
    ( Debug.toString (eval program tp)
    , Cmd.none
    )



-- UPDATE


type alias Msg =
    {}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ text model ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- TM


{-| ヘッドの移動方向
-}
type D
    = L -- Left
    | R -- Right


{-| 記号
-}
type S
    = B -- Blank
    | I -- 1
    | O -- 0


{-| 状態
-}
type Q
    = M
    | H


{-| 遷移関数
-}
type alias Delta =
    List ( ( Q, S ), ( Q, S, D ) )


{-| プログラム
-}
type alias P =
    ( Q, Delta )


{-| テープ
-}
type alias Tape =
    ( List S, S, List S )


program : P
program =
    ( M
    , [ ( ( M, I ), ( M, O, L ) )
      , ( ( M, O ), ( M, I, L ) )
      , ( ( M, B ), ( H, I, L ) )
      ]
    )


tp : Tape
tp =
    ( [ I, I, I ], I, [] )


{-| プログラムとテープに対する計算をする関数
-}
eval : P -> Tape -> Tape
eval ( p, delta ) tape =
    exec delta ( p, tape )


{-| テープを左右に動かす関数
-}
move : D -> Tape -> Tape
move d tape =
    case d of
        L ->
            moveL tape

        R ->
            moveR tape


{-| リストを左に動かす関数
-}
moveL : Tape -> Tape
moveL ( ll, h, rl ) =
    ( tl ll, hd ll, cons ( h, rl ) )


{-| リストを右に動かす関数
-}
moveR : Tape -> Tape
moveR ( ll, h, rl ) =
    ( cons ( h, ll ), hd rl, tl rl )


{-| 状態遷移を実行する関数
-}
exec : Delta -> ( Q, Tape ) -> Tape
exec delta ( q, tape ) =
    let
        ( ll, h, rl ) =
            tape
    in
    case List.find (\( x, y ) -> x == ( q, h )) delta of
        Nothing ->
            ( ll, h, rl )

        Just ( x, ( qq, s, d ) ) ->
            exec delta ( qq, move d ( ll, s, rl ) )


{-| 先頭要素を取り出す関数
-}
hd : List S -> S
hd list =
    case list of
        [] ->
            B

        s :: _ ->
            s


{-| 先頭要素を除いた残りのリストを返す関数
-}
tl : List S -> List S
tl list =
    case list of
        [] ->
            []

        _ :: ss ->
            ss


{-| リストの先頭に要素を付け加える関数
-}
cons : ( S, List S ) -> List S
cons ( h, t ) =
    h :: t
