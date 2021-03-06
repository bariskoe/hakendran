import 'package:baristodolistapp/models/todo_model.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/todolist_entity.dart';
import '../../domain/failures/failures.dart';
import '../../domain/repositories/selected_todolist_repository.dart';
import '../datasources/local_sqlite_datasource.dart';

class SelectedTodoListRepositoryImpl implements SelectedTodolistRepository {
  final LocalSqliteDataSource localSqliteDataSource;
  SelectedTodoListRepositoryImpl({
    required this.localSqliteDataSource,
  });

  @override
  Future<Either<Failure, TodoListEntity>> getSpecificTodoList({
    required int id,
  }) async {
    try {
      final todoListModel =
          await localSqliteDataSource.getSpecificTodoList(id: id);
      return Right(todoListModel);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, int>> addTodoToSpecificList({
    required TodoModel todoModel,
  }) async {
    try {
      final int success = await localSqliteDataSource.addTodoToSpecificList(
          todoModel: todoModel);
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, int>> setAccomplishmentStatusOfTodo({
    required int id,
    required bool accomplished,
  }) async {
    try {
      int changes = await localSqliteDataSource.setAccomplishmentStatusOfTodo(
        id: id,
        accomplished: accomplished,
      );
      return Right(changes);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, int>> updateSpecificTodo({
    required TodoModel todoModel,
  }) async {
    try {
      int changes = await localSqliteDataSource.updateSpecificTodo(
        todoModel: todoModel,
      );
      return Right(changes);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, int>> resetAllTodosOfSpecificList({
    required int id,
  }) async {
    try {
      int changes = await localSqliteDataSource.resetAllTodosOfSpecificList(
        id: id,
      );
      return Right(changes);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }
}
