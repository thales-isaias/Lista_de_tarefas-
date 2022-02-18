import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/models/todo.dart';
import 'dart:convert';

const todoListKey = 'todo_list';

class TodoRepository {
  late SharedPreferences sharedPreferences;

  Future<List<Todo>> getTodoList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(todoListKey) ?? '[]';
    final List jsonDecod = jsonDecode(jsonString) as List;
    return jsonDecod.map((e) => Todo.fromJson(e)).toList();
  }

  void saveTodoList(List<Todo> todos) {
    final String jsonString = json.encode(todos);
    sharedPreferences.setString('todo_list', jsonString);
  }
}
