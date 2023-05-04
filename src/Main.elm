module Main exposing (..)

import Browser
import Html as H exposing (Html)
import Html.Attributes as Attr
import Http
import Task
import Yaml.Decode as YD



-- TYPES


type alias AppState =
    { rawYamlString : String
    , profileData : Maybe ProfileData
    }


type alias ProfileData =
    Result String (List Section)


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
    ( { rawYamlString = ""
      , profileData = Nothing
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
            ( { appState
                | profileData = Just <| Result.mapError YD.errorToString yamlResult

                -- | profileData = Nothing
              }
            , Cmd.none
            )


view : AppState -> Html Msg
view appState =
    if appState.profileData == Nothing then
        pageWrapper (H.div [ Attr.class "mt-6" ] [ H.text "Hold on a moment..." ])

    else
        pageWrapper
            (H.div [ Attr.class "mt-6" ]
                [ viewSectionsOrError (Maybe.withDefault (Ok []) appState.profileData)
                ]
            )


viewHeader : Html Msg
viewHeader =
    H.div []
        [ H.div [ Attr.class "" ] [ H.img [ Attr.src "/logo.png", Attr.class "text-center w-16 dark:invert" ] [] ]
        , H.h1 [ Attr.class "mt-6" ] [ H.text "Hi, I'm Chandru." ]
        , H.p [ Attr.class "mt-2" ] [ H.text "I am a frontend dev and a few other things." ]
        , H.hr [ Attr.class "mt-6" ] []
        ]


viewSection : Section -> Html Msg
viewSection section =
    H.div []
        [ H.h2 [ Attr.class "uppercase text-xs text-zinc-400" ] [ H.text section.name ]
        , H.div [ Attr.class "mt-3 lg:mt-2 space-y-2" ] (viewItems section.items)
        ]


viewSections : List Section -> List (Html Msg)
viewSections data =
    if List.length data > 0 then
        List.map viewSection data

    else
        [ H.span [ Attr.class "text-red-400" ] [ H.text "Data drives the world. And this site. But something's wrong and there's no data to load. :(" ]
        ]


viewSectionsOrError : Result String (List Section) -> Html Msg
viewSectionsOrError profileData =
    case profileData of
        Err e ->
            H.div []
                [ H.div [ Attr.class "text-red-400" ] [ H.text "Metamorphosis of a chrysalis went horribly wrong:" ]
                , H.div [] [ H.text e ]
                ]

        Ok data ->
            H.div [ Attr.class "space-y-8" ] (viewSections data)


viewItems : List Item -> List (Html Msg)
viewItems =
    List.map viewItem


viewItem : Item -> Html Msg
viewItem item =
    let
        renderItemName : Item -> List (Html Msg)
        renderItemName item_ =
            case item_.link of
                Nothing ->
                    [ H.text item_.name ]

                Just l ->
                    [ H.a [ Attr.href l, Attr.target "blank" ] [ H.text item_.name ] ]
    in
    H.div [ Attr.class "flex flex-col md:grid md:grid-cols-12" ]
        [ H.span [ Attr.class "font-semibold text-stone-500 md:col-span-5 lg:col-span-4" ] (renderItemName item)
        , H.span [ Attr.class "md:col-span-7 lg:col-span-8" ] [ H.text item.description ]
        ]


pageWrapper : Html Msg -> Html Msg
pageWrapper contents =
    H.div [] [ viewHeader, contents ]



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
