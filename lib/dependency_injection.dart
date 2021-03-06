import 'domain/repositories/selected_todolist_repository.dart';
import 'infrastructure/repositories/selected_todolist_repository_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/allTodoLists/all_todolists_bloc.dart';
import 'bloc/selectedTodolist_bloc/bloc/selected_todolist_bloc.dart';
import 'domain/repositories/all_todolists_repository.dart';
import 'domain/usecases/all_todolists_usecases.dart';
import 'domain/usecases/selected_todolist_usecases.dart';
import 'infrastructure/datasources/local_sqlite_datasource.dart';
import 'infrastructure/datasources/local_sqlite_datasource_impl.dart';
import 'infrastructure/repositories/all_todo_lists_repository_impl.dart';

final getIt = GetIt.I;

Future<void> setupDependencyInjectionWithGetIt() async {
//! application layer
  getIt.registerFactory(() => AllTodolistsBloc(
      allTodoListsUsecases: getIt(), selectedTodolistBloc: getIt()));
  getIt.registerFactory(
      () => SelectedTodolistBloc(selectedTodolistUsecases: getIt()));

//! Usecases
  getIt.registerLazySingleton(
      () => AllTodoListsUsecases(allTodoListsRepository: getIt()));
  getIt.registerLazySingleton(
      () => SelectedTodolistUsecases(selectedTodolistRepository: getIt()));

//! repos
  getIt.registerLazySingleton<AllTodoListsRepository>(
      () => AllTodoListsRepositoryImpl(localSqliteDataSource: getIt()));
  getIt.registerLazySingleton<SelectedTodolistRepository>(
      () => SelectedTodoListRepositoryImpl(localSqliteDataSource: getIt()));

  getIt.registerLazySingleton<LocalSqliteDataSource>(
      () => LocalSqliteDataSourceImpl());

  //getIt.registerLazySingleton(() => TodosBlocBloc());
  getIt.registerSingleton(await SharedPreferences.getInstance());
}
