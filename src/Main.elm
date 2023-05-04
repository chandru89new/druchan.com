module Main exposing (..)

import Browser
import Html as H exposing (Html)
import Http
import Task
import Yaml.Decode as YD



-- TYPES


type alias AppState =
    { appDataLoading : Bool
    , rawYamlString : String
    , profileData : List Section
    , yamlParserError : Maybe String
    }


type Msg
    = NoOp
    | GetYamlData
    | GotYamlData (Result Http.Error String)
    | ParseYamlData String


type alias Section =
    { name : String
    , items : List Item
    }


type alias Item =
    { name : String
    , description : String
    , link : Maybe String
    }



-- END TYPES


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


init : () -> ( AppState, Cmd Msg )
init _ =
    ( { appDataLoading = True
      , rawYamlString = ""
      , profileData = []
      , yamlParserError = Nothing
      }
    , Cmd.batch
        [ Task.perform (\_ -> GetYamlData) (Task.succeed ())
        ]
    )


update : Msg -> AppState -> ( AppState, Cmd Msg )
update msg appState =
    case msg of
        NoOp ->
            ( appState, Cmd.none )

        GetYamlData ->
            ( appState, Http.get { url = "/data.yml", expect = Http.expectString GotYamlData } )

        GotYamlData res ->
            case res of
                Ok yamlString ->
                    ( { appState | rawYamlString = yamlString }, msgToCmd ParseYamlData yamlString )

                Err _ ->
                    ( appState, Cmd.none )

        ParseYamlData yamlString ->
            let
                yamlResult =
                    YD.fromString decodeYaml yamlString
            in
            case yamlResult of
                Ok data ->
                    ( { appState
                        | profileData = data
                        , appDataLoading = False
                        , yamlParserError = Nothing
                      }
                    , Cmd.none
                    )

                Err e ->
                    ( { appState
                        | appDataLoading = False
                        , yamlParserError = Just <| YD.errorToString e
                      }
                    , Cmd.none
                    )


view : AppState -> Html Msg
view appState =
    H.div [] [ H.text <| Debug.toString appState.profileData ]



-- UTILITIES


decodeItem : YD.Decoder Item
decodeItem =
    YD.map3 (\name description link -> Item name description link)
        (YD.field "name" YD.string)
        (YD.field "description" YD.string)
        (YD.maybe (YD.field "link" YD.string))


decodeSection : YD.Decoder Section
decodeSection =
    YD.map2 (\name items -> Section name items)
        (YD.field "name" YD.string)
        (YD.field "items" (YD.list decodeItem))


decodeYaml : YD.Decoder (List Section)
decodeYaml =
    YD.field "sections" (YD.list decodeSection)


msgToCmd : (a -> msg) -> a -> Cmd msg
msgToCmd toMsg arg =
    Task.perform toMsg (Task.succeed arg)



-- END UTILITIES
