module Introduction.Resize exposing (Model, Msg, initialModel, main, subscriptions, update, view)

import Browser
import DnDList
import DnDList.Single
import Html
import Html.Attributes



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- DATA


type alias Color =
    String


data : List Color
data =
    [ yellow
    , pink
    , blue
    , green
    , orange
    ]


type alias Spot =
    { width : Int
    , height : Int
    }


spots : List Spot
spots =
    [ Spot 1 1
    , Spot 1 3
    , Spot 2 2
    , Spot 2 1
    , Spot 2 3
    ]



-- DND


system : DnDList.Single.System Color Msg
system =
    DnDList.Single.config
        |> DnDList.Single.operation DnDList.Swap
        |> DnDList.Single.ghost [ "position" ]
        |> DnDList.Single.create DnDMsg



-- MODEL


type alias Model =
    { colors : List Color
    , dnd : DnDList.Single.Model
    }


initialModel : Model
initialModel =
    { colors = data
    , dnd = system.model
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( initialModel, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    system.subscriptions model.dnd



-- UPDATE


type Msg
    = DnDMsg DnDList.Single.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DnDMsg dndMsg ->
            let
                ( colors, dndModel, dndCmd ) =
                    system.update model.colors dndMsg model.dnd
            in
            ( { model | colors = colors, dnd = dndModel }
            , dndCmd
            )



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.section []
        [ List.map2 (\color spot -> ( color, spot )) model.colors spots
            |> List.indexedMap (itemView model)
            |> Html.div containerStyles
        , ghostView model
        ]


itemView : Model -> Int -> ( Color, Spot ) -> Html.Html Msg
itemView model index ( color, spot ) =
    let
        itemId : String
        itemId =
            "id-" ++ String.fromInt index

        width : Int
        width =
            spot.width * 5

        height : Int
        height =
            spot.height * 5
    in
    case system.info model.dnd of
        Just { dragIndex } ->
            if index /= dragIndex then
                Html.div
                    (Html.Attributes.id itemId
                        :: itemStyles width height color
                        ++ system.dropEvents index itemId
                    )
                    [ Html.div handleStyles [ Html.text "⠶" ] ]

            else
                Html.div
                    (Html.Attributes.id itemId :: itemStyles width height gray)
                    []

        _ ->
            Html.div
                (Html.Attributes.id itemId :: itemStyles width height color)
                [ Html.div
                    (handleStyles ++ system.dragEvents index itemId)
                    [ Html.text "⠶" ]
                ]


ghostView : Model -> Html.Html Msg
ghostView model =
    case ( system.info model.dnd, maybeDragItem model ) of
        ( Just { dropElement }, Just color ) ->
            let
                width : Int
                width =
                    round dropElement.element.width

                height : Int
                height =
                    round dropElement.element.height
            in
            Html.div
                (itemStyles width height color
                    ++ system.ghostStyles model.dnd
                    ++ [ Html.Attributes.style "width" (String.fromInt width ++ "px")
                       , Html.Attributes.style "height" (String.fromInt height ++ "px")
                       , Html.Attributes.style "transition" "width 0.5s, height 0.5s"
                       ]
                )
                [ Html.div handleStyles [ Html.text "⠶" ] ]

        _ ->
            Html.text ""



-- HELPERS


maybeDragItem : Model -> Maybe Color
maybeDragItem { dnd, colors } =
    system.info dnd
        |> Maybe.andThen (\{ dragIndex } -> colors |> List.drop dragIndex |> List.head)



-- COLORS


pink : Color
pink =
    "#c151a7"


blue : Color
blue =
    "#0696c5"


orange : Color
orange =
    "#e9513e"


green : Color
green =
    "#768402"


yellow : Color
yellow =
    "#efa500"


gray : Color
gray =
    "dimgray"



-- STYLES


containerStyles : List (Html.Attribute msg)
containerStyles =
    [ Html.Attributes.style "display" "flex"
    , Html.Attributes.style "flex-wrap" "wrap"
    , Html.Attributes.style "align-items" "center"
    , Html.Attributes.style "justify-content" "center"
    , Html.Attributes.style "padding-top" "3em"
    ]


itemStyles : Int -> Int -> String -> List (Html.Attribute msg)
itemStyles width height color =
    [ Html.Attributes.style "border-radius" "8px"
    , Html.Attributes.style "margin" "0 3em 3em 0"
    , Html.Attributes.style "display" "flex"
    , Html.Attributes.style "align-items" "flex-start"
    , Html.Attributes.style "justify-content" "flex-start"
    , Html.Attributes.style "background-color" color
    , Html.Attributes.style "width" (String.fromInt width ++ "rem")
    , Html.Attributes.style "height" (String.fromInt height ++ "rem")
    ]


handleStyles : List (Html.Attribute msg)
handleStyles =
    [ Html.Attributes.style "width" "60px"
    , Html.Attributes.style "height" "60px"
    , Html.Attributes.style "color" "black"
    , Html.Attributes.style "cursor" "pointer"
    , Html.Attributes.style "display" "flex"
    , Html.Attributes.style "align-items" "center"
    , Html.Attributes.style "justify-content" "center"
    ]
