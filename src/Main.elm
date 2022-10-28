module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http



---- MODEL ----


type alias Model =
    { heading : String
    , factText : String
    , input : String
    }


init : ( Model, Cmd Msg )
init =
    ( { heading = "Cat Facts"
      , factText = "Click the button to get a cat fact"
      , input = ""
      }
    , Cmd.none
    )


type Msg
    = ShowFacts
    | Input String
    | NewFactArrived (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input newInput ->
            ( Model "NumbersApi typing.." "" newInput, Cmd.none )

        ShowFacts ->
            let
                url =
                    "https://jsonplaceholder.typicode.com/todos/" ++ model.input

                sendRequest =
                    Http.get
                        { url = url
                        , expect = Http.expectString NewFactArrived
                        }
            in
            ( model, sendRequest )

        NewFactArrived (Ok fact) ->
            ( Model "NumbersApi" fact model.input, Cmd.none )

        NewFactArrived (Err _) ->
            ( Model model.input "not valid value" "", Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text model.heading ]
        , input [ onInput Input, value model.input ] []
        , button [ onClick ShowFacts ] [ text "show facts" ]
        , br [] []
        , h3 [] [ text model.factText ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
