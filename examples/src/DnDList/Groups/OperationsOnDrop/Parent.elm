module DnDList.Groups.OperationsOnDrop.Parent exposing
    ( Model
    , Msg
    , init
    , initialModel
    , subscriptions
    , update
    , url
    , view
    )

import DnDList.Groups.OperationsOnDrop.InsertAfter
import DnDList.Groups.OperationsOnDrop.InsertBefore
import DnDList.Groups.OperationsOnDrop.Rotate
import DnDList.Groups.OperationsOnDrop.Swap
import Html
import Views



-- MODEL


type alias Model =
    { id : Int
    , examples : List Example
    }


type Example
    = InsertAfter DnDList.Groups.OperationsOnDrop.InsertAfter.Model
    | InsertBefore DnDList.Groups.OperationsOnDrop.InsertBefore.Model
    | Rotate DnDList.Groups.OperationsOnDrop.Rotate.Model
    | Swap DnDList.Groups.OperationsOnDrop.Swap.Model


initialModel : Model
initialModel =
    { id = 0
    , examples =
        [ InsertAfter DnDList.Groups.OperationsOnDrop.InsertAfter.initialModel
        , InsertBefore DnDList.Groups.OperationsOnDrop.InsertBefore.initialModel
        , Rotate DnDList.Groups.OperationsOnDrop.Rotate.initialModel
        , Swap DnDList.Groups.OperationsOnDrop.Swap.initialModel
        ]
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( initialModel, Cmd.none )


url : Int -> String
url id =
    case id of
        0 ->
            "https://raw.githubusercontent.com/annaghi/dnd-list/master/examples/src/DnDList.Groups/OperationsOnDrop/DetectReorder.elm"

        1 ->
            "https://raw.githubusercontent.com/annaghi/dnd-list/master/examples/src/DnDList.Groups/OperationsOnDrop/InsertBefore.elm"

        2 ->
            "https://raw.githubusercontent.com/annaghi/dnd-list/master/examples/src/DnDList.Groups/OperationsOnDrop/Rotate.elm"

        3 ->
            "https://raw.githubusercontent.com/annaghi/dnd-list/master/examples/src/DnDList.Groups/OperationsOnDrop/DetectReorder.elm"

        _ ->
            ""



-- UPDATE


type Msg
    = LinkClicked Int
    | InsertAfterMsg DnDList.Groups.OperationsOnDrop.InsertAfter.Msg
    | InsertBeforeMsg DnDList.Groups.OperationsOnDrop.InsertBefore.Msg
    | RotateMsg DnDList.Groups.OperationsOnDrop.Rotate.Msg
    | SwapMsg DnDList.Groups.OperationsOnDrop.Swap.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        LinkClicked id ->
            ( { model | id = id }, Cmd.none )

        _ ->
            model.examples
                |> List.map
                    (\example ->
                        case ( message, example ) of
                            ( InsertAfterMsg msg, InsertAfter mo ) ->
                                stepInsertAfter (DnDList.Groups.OperationsOnDrop.InsertAfter.update msg mo)

                            ( InsertBeforeMsg msg, InsertBefore mo ) ->
                                stepInsertBefore (DnDList.Groups.OperationsOnDrop.InsertBefore.update msg mo)

                            ( RotateMsg msg, Rotate mo ) ->
                                stepRotate (DnDList.Groups.OperationsOnDrop.Rotate.update msg mo)

                            ( SwapMsg msg, Swap mo ) ->
                                stepSwap (DnDList.Groups.OperationsOnDrop.Swap.update msg mo)

                            _ ->
                                ( example, Cmd.none )
                    )
                |> List.unzip
                |> (\( examples, cmds ) -> ( { model | examples = examples }, Cmd.batch cmds ))


stepInsertAfter : ( DnDList.Groups.OperationsOnDrop.InsertAfter.Model, Cmd DnDList.Groups.OperationsOnDrop.InsertAfter.Msg ) -> ( Example, Cmd Msg )
stepInsertAfter ( mo, cmds ) =
    ( InsertAfter mo, Cmd.map InsertAfterMsg cmds )


stepInsertBefore : ( DnDList.Groups.OperationsOnDrop.InsertBefore.Model, Cmd DnDList.Groups.OperationsOnDrop.InsertBefore.Msg ) -> ( Example, Cmd Msg )
stepInsertBefore ( mo, cmds ) =
    ( InsertBefore mo, Cmd.map InsertBeforeMsg cmds )


stepRotate : ( DnDList.Groups.OperationsOnDrop.Rotate.Model, Cmd DnDList.Groups.OperationsOnDrop.Rotate.Msg ) -> ( Example, Cmd Msg )
stepRotate ( mo, cmds ) =
    ( Rotate mo, Cmd.map RotateMsg cmds )


stepSwap : ( DnDList.Groups.OperationsOnDrop.Swap.Model, Cmd DnDList.Groups.OperationsOnDrop.Swap.Msg ) -> ( Example, Cmd Msg )
stepSwap ( mo, cmds ) =
    ( Swap mo, Cmd.map SwapMsg cmds )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    model.examples
        |> List.map
            (\example ->
                case example of
                    InsertAfter mo ->
                        Sub.map InsertAfterMsg (DnDList.Groups.OperationsOnDrop.InsertAfter.subscriptions mo)

                    InsertBefore mo ->
                        Sub.map InsertBeforeMsg (DnDList.Groups.OperationsOnDrop.InsertBefore.subscriptions mo)

                    Rotate mo ->
                        Sub.map RotateMsg (DnDList.Groups.OperationsOnDrop.Rotate.subscriptions mo)

                    Swap mo ->
                        Sub.map SwapMsg (DnDList.Groups.OperationsOnDrop.Swap.subscriptions mo)
            )
        |> Sub.batch



-- VIEW


view : Model -> Html.Html Msg
view model =
    Views.examplesView LinkClicked info model.id model.examples


info : Example -> Views.SubInfo Msg
info example =
    case example of
        InsertAfter mo ->
            { title = "Insert after"
            , subView = Html.map InsertAfterMsg (DnDList.Groups.OperationsOnDrop.InsertAfter.view mo)
            }

        InsertBefore mo ->
            { title = "Insert before"
            , subView = Html.map InsertBeforeMsg (DnDList.Groups.OperationsOnDrop.InsertBefore.view mo)
            }

        Rotate mo ->
            { title = "Rotate"
            , subView = Html.map RotateMsg (DnDList.Groups.OperationsOnDrop.Rotate.view mo)
            }

        Swap mo ->
            { title = "Swap"
            , subView = Html.map SwapMsg (DnDList.Groups.OperationsOnDrop.Swap.view mo)
            }
