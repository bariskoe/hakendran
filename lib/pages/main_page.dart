import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../assets.dart';
import '../bloc/allTodoLists/all_todolists_bloc.dart';
import '../bloc/selectedTodolist_bloc/bloc/selected_todolist_bloc.dart';
import '../dialogs/add_list_dialog.dart';
import '../dialogs/edit_todolist_dialog.dart';
import '../drawers/main_page_drawer.dart';
import '../models/todolist_model.dart';
import '../ui/constants/constants.dart';
import '../ui/standard_widgets/error_box_widget.dart';
import '../ui/standard_widgets/loading_widget.dart';
import '../ui/standard_widgets/standard_page_widget.dart';
import '../ui/standard_widgets/standard_ui_widgets.dart';
import '../ui/standard_widgets/standart_text_widgets.dart';
import '../ui/widgets/page_background_image_widget.dart';
import 'todo_detail_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    Key? key,
  }) : super(key: key);

  static bool justDismissedList = false;
//The AllTodoLIstBloc sets justAddedTodo to true when an AddList event
  //comes in
  static bool justAddedList = false;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.linearToEaseOut,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StandardPageWidget(
      appbarActions: [
        Builder(builder: (context) {
          return GestureDetector(
            child: const Padding(
              padding: EdgeInsets.only(right: UiConstantsPadding.xlarge),
              child: Icon(Icons.settings),
            ),
            onTap: () => Scaffold.of(context).openEndDrawer(),
          );
        })
      ],
      drawer: mainPageDrawer(),
      willPop: false,
      appBarTitle: AppLocalizations.of(context)?.mainPageAppbarTitle,
      child: Stack(
        children: [
          BlocBuilder<AllTodolistsBloc, AllTodolistsState>(
            buildWhen: (previous, current) =>
                current != AllTodoListsStateLoading(),
            builder: (context, state) {
              if (MainPage.justAddedList) {
                _controller?.reset();
                _controller?.forward().then((value) {
                  MainPage.justAddedList = false;
                });
              }

              if (state is AllTodoListsStateLoaded) {
                return Container(
                  child: _buildListLoaded(state, context),
                );
              }
              if (state is AllTodolistsInitial) {
                BlocProvider.of<AllTodolistsBloc>(context).add(
                  AllTodolistsEventGetAllTodoLists(),
                );
              }
              if (state is AllTodoListsStateError) {
                return const ErrorBoxWidget();
              }
              if (state is AllTodoListsStateListEmpty) {
                return _buildListEmpty(context);
              }

              return BigListElementText(
                  text: AppLocalizations.of(context)!.somethingWentWrong);
            },
          ),
          BlocBuilder<AllTodolistsBloc, AllTodolistsState>(
            builder: (context, state) {
              return FABrow(
                state: state,
              );
            },
          ),
          BlocBuilder<AllTodolistsBloc, AllTodolistsState>(
            builder: (context, state) {
              if (state is AllTodoListsStateLoading) {
                return const LoadingWidget();
              } else {
                return Container();
              }
            },
          )
        ],
      ),
    );
  }

  _buildListEmpty(BuildContext context) {
    return Stack(
      children: [
        PageBackGroundImageWidget(imagePath: ImageAssets.sleepingYellowCat),
        Center(
            child: GestureDetector(
          onTap: () {
            addListDialog(context);
          },
          child: Container(
              padding: const EdgeInsets.all(UiConstantsPadding.xlarge),
              width: 270,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(UiConstantsRadius.large))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)
                            ?.mainPageBuildListEmptyLazinessIsOver ??
                        'null',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(
                    height: UiConstantsPadding.large,
                  ),
                  Text(
                    AppLocalizations.of(context)
                            ?.mainPageBuildListEmptyPressToAddTodoList ??
                        'null',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  )
                ],
              )),
        ))
      ],
    );
  }

  _buildListLoaded(AllTodoListsStateLoaded state, BuildContext context) {
    //Sorts the list by property 'accomplished'
    List<TodoListModel> list = state.listOfAllLists;
    list.sort(((a, b) => b.allAccomplished ? 1 : -1));
    List<TodoListModel> reversedList = List.from(list.reversed);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: reversedList.length + 1,
      itemBuilder: ((context, index) {
        if (index == reversedList.length) {
          return Container(
            height: 100,
          );
        } else {
          TodoListModel model = reversedList[index];
          return index == 0 && MainPage.justAddedList
              ? SizeTransition(
                  sizeFactor: _animation!,
                  axis: Axis.vertical,
                  child: DismissibleListElement(
                    model: model,
                  ),
                )
              : DismissibleListElement(
                  model: model,
                );
        }
      }),
    );
  }
}

class DismissibleListElement extends StatelessWidget {
  const DismissibleListElement({
    Key? key,
    required this.model,
  }) : super(key: key);

  final TodoListModel model;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(
        model.toString(),
      ),
      background: const SwipeToDeleteBackgroundWidget(),
      onDismissed: (dismissdirection) {
        MainPage.justDismissedList = true;
        BlocProvider.of<AllTodolistsBloc>(context).add(
          AllTodolistsEventDeleteSpecificTodolist(id: model.id!),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: UiConstantsPadding.xlarge,
            vertical: UiConstantsPadding.large),
        child: GestureDetector(
          child: MainPageListItemWidget(
            todoListModel: model,
          ),
          onTap: () {
            BlocProvider.of<SelectedTodolistBloc>(context).add(
              SelectedTodoListEventSelectSpecificTodoList(id: model.id!),
            );

            BlocProvider.of<SelectedTodolistBloc>(context).add(
              SelectedTodolistEventLoadSelectedTodolist(id: model.id!),
            );

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TodoListDetailPage(),
                ));
          },
          onLongPress: () => editListDialog(
            context,
            model,
          ),
        ),
      ),
    );
  }
}

class MainPageListItemWidget extends StatelessWidget {
  const MainPageListItemWidget({required this.todoListModel, Key? key})
      : super(key: key);
  final TodoListModel todoListModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: UiConstantsPadding.xlarge),
      decoration: StandardUiWidgets.standardBoxDecoration(
          context,
          todoListModel.allAccomplished
              ? UiConstantsColors.allAccomplishedGradientColors
              : null),
      child: Row(
        children: [
          Expanded(
            child: BigListElementText(text: todoListModel.listName),
          ),
          Padding(
            padding: const EdgeInsets.all(UiConstantsPadding.small),
            child: ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [
                    0,
                    todoListModel.percentageOfAccomplishedTodos,
                    todoListModel.percentageOfAccomplishedTodos
                  ],
                  tileMode: TileMode.clamp,
                  colors: <Color>[
                    Colors.amber,
                    Colors.amber,
                    Colors.white.withOpacity(0)
                  ],
                ).createShader(bounds);
              },
              child: Icon(todoListModel.todoListCategory.getIcon(),
                  color: Colors.white, size: UiConstantsSize.xlarge),
            ),
          ),
        ],
      ),
    );
  }
}

class FABrow extends StatefulWidget {
  const FABrow({
    Key? key,
    required this.state,
  }) : super(key: key);
  final AllTodolistsState state;

  @override
  State<FABrow> createState() => _FABrowState();
}

class _FABrowState extends State<FABrow> {
  double turns = 0.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(UiConstantsPadding.xlarge),
          child: Align(
              alignment: Alignment.bottomRight,
              child: AnimatedRotation(
                turns: turns,
                duration: const Duration(seconds: 1),
                child: FloatingActionButton(
                    heroTag: const Text('button3'),
                    child: const Icon(Icons.refresh),
                    onPressed: () {
                      turns++;
                      BlocProvider.of<AllTodolistsBloc>(context).add(
                        AllTodolistsEventGetAllTodoLists(),
                      );
                    }),
              )),
        ),
        if (widget.state != AllTodoListsStateError()) ...[
          Padding(
            padding: const EdgeInsets.all(UiConstantsPadding.xlarge),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: const Text('button2'),
                child: const Icon(Icons.add),
                onPressed: () => addListDialog(context),
              ),
            ),
          ),
        ]
      ],
    );
  }
}
