import 'package:todo_list/models/todo.dart';
import 'package:todo_list/repositories/todo_repository.dart';
import 'package:todo_list/widgets/todo_list_item.dart';
import 'package:flutter/material.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> todos = [];
  Todo? deletedTodo;
  int? deletedTodoPos;
  final TextEditingController todosController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  String? erroText;

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Center(
        child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todosController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Adicione uma tarefa",
                            hintText: "Ex.. Estudar",
                            errorText: erroText,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.greenAccent,
                                width: 3,
                              ),
                            ),
                            labelStyle: TextStyle(color: Colors.greenAccent)),
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String text = todosController.text;

                        if (text.isEmpty) {
                          setState(() {
                            erroText = 'O titulo não pode ser vazio!';
                          });

                          return;
                        }

                        setState(() {
                          Todo newTodo =
                              Todo(title: text, dateTime: DateTime.now());
                          todos.add(newTodo);
                          erroText = null;
                        });
                        todosController.clear();
                        todoRepository.saveTodoList(todos);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.greenAccent,
                        padding: EdgeInsets.all(14),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 30.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child:
                          Text('Você possui ${todos.length} tarefas pendentes'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.greenAccent,
                        padding: EdgeInsets.all(14),
                      ),
                      onPressed: showDeleteTodosConfirmationDialog,
                      child: Text('Limpar tudo'),
                    )
                  ],
                ),
              ],
            )),
      )),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
            'Tarefa ${todo.title} foi removida com sucesso!',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          action: SnackBarAction(
            label: 'Desfazer',
            textColor: Colors.greenAccent,
            onPressed: () {
              setState(() {
                todos.insert(deletedTodoPos!, deletedTodo!);
              });
              todoRepository.saveTodoList(todos);
            },
          ),
          duration: const Duration(
            seconds: 5,
          )),
    );
  }

  void showDeleteTodosConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limapar tudo?'),
        content: Text('Você tem certeza que deseja apagar todas as tarefas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(primary: Colors.greenAccent),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTodos();
            },
            style: TextButton.styleFrom(primary: Colors.red),
            child: Text('Limpar tudo'),
          )
        ],
      ),
    );
  }

  void deleteAllTodos() {
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }
}
