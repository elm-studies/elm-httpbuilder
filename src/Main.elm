module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import HttpBuilder
import Json.Decode as D exposing (Decoder)



---- MODEL ----


type alias Model =
    { heading : String
    , factText : String
    , input : String
    , dummy_id : Int
    , dummy_userId : Int
    , dummy_title : String
    , dummy_body : String
    }


type alias DummyUser =
    { id : Int
    , userId : Int
    , title : String
    , body : String
    }


init : ( Model, Cmd Msg )
init =
    ( { heading = "Cat Facts"
      , factText = "Click the button to get a cat fact"
      , input = ""
      , dummy_id = 0
      , dummy_userId = 0
      , dummy_title = ""
      , dummy_body = ""
      }
    , Cmd.none
    )


type Msg
    = ShowFacts
    | Input String
    | DummyUserArrived DummyUser
    | NoOp


userInformationDecoder : Decoder DummyUser
userInformationDecoder =
    D.map4
        DummyUser
        (D.field "userId" D.int)
        (D.field "id" D.int)
        (D.field "title" D.string)
        (D.field "body" D.string)


handleFetchUserRequest : Result Http.Error DummyUser -> Msg
handleFetchUserRequest result =
    let
        o =
            case result of
                Ok user ->
                    user

                Err _ ->
                    { id = 0
                    , userId = 0
                    , title = ""
                    , body = ""
                    }
    in
    DummyUserArrived o


getFromApi : String -> Cmd Msg
getFromApi inputValue =
    let
        url =
            "https://jsonplaceholder.typicode.com/posts/" ++ inputValue
    in
    HttpBuilder.get url
        |> HttpBuilder.withExpect
            (Http.expectJson handleFetchUserRequest
                userInformationDecoder
            )
        |> HttpBuilder.request


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input newInput ->
            ( { model
                | input = newInput
                , factText = "NumbersApi is typing..."
              }
            , Cmd.none
            )

        ShowFacts ->
            ( model, getFromApi model.input )

        DummyUserArrived user ->
            ( { model
                | dummy_id = user.id
                , dummy_userId = user.userId
                , dummy_title = user.title
                , dummy_body = user.body
              }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text model.heading ]
        , input [ onInput Input, value model.input ] []
        , button [ onClick ShowFacts ] [ text "show facts" ]
        , br [] []
        , h3 [] [ text model.factText ]
        , p [] [ text (String.fromInt model.dummy_userId) ]
        , p [] [ text model.dummy_body ]
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
