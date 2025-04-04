import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Todo {
  String id;
  String title;
  DateTime dueDate;
  bool isCompleted;
  String userId;

  Todo({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }

  static Todo fromMap(Map<String, dynamic> map, String documentId) {
    return Todo(
      id: documentId,
      title: map['title'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'],
      userId: map['userId'],
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _todoController = TextEditingController();
  DateTime? _selectedDate;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addTodo() async {
    if (_todoController.text.isNotEmpty && _selectedDate != null) {
      String userId = _auth.currentUser!.uid;
      DocumentReference docRef = _firestore.collection('todos').doc();

      Todo newTodo = Todo(
        id: docRef.id,
        title: _todoController.text,
        dueDate: _selectedDate!,
        userId: userId,
      );

      await docRef.set(newTodo.toMap());
      _todoController.clear();
      _selectedDate = null;
      setState(() {});
    }
  }

  void _toggleCompletion(Todo todo) async {
    await _firestore
        .collection('todos')
        .doc(todo.id)
        .update({'isCompleted': !todo.isCompleted});
  }

  void _deleteTodo(String id) async {
    await _firestore.collection('todos').doc(id).delete();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = _auth.currentUser!.uid;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 142, 186, 236), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color:Color.fromARGB(255, 4, 39, 116)),
                  onPressed: () => Navigator.pop(context),
                ),
                
                Center(
                  child: const Text(
                    "To-Do List",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 4, 39, 116),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _todoController,
                        decoration: InputDecoration(
                          labelText: "Enter your task",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? "Select due date"
                                  : DateFormat.yMd().format(_selectedDate!),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _addTodo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 60, 149, 245),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Add Task"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('todos')
                          .where('userId', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        List<Todo> todos = snapshot.data!.docs.map((doc) {
                          return Todo.fromMap(
                              doc.data() as Map<String, dynamic>, doc.id);
                        }).toList();

                        List<Todo> activeTodos =
                            todos.where((t) => !t.isCompleted).toList();
                        List<Todo> completedTodos =
                            todos.where((t) => t.isCompleted).toList();

                        return ListView(
                          children: [
                            _buildTodoSection("Upcoming Tasks", activeTodos),
                            if (completedTodos.isNotEmpty)
                              _buildTodoSection("Completed Tasks", completedTodos),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodoSection(String title, List<Todo> todos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (todos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6, left: 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 4, 39, 116),
              ),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                title: Text(
                  todo.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: todo.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                subtitle: Text(
                  "Due: ${DateFormat.yMd().add_jm().format(todo.dueDate)}",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: todo.isCompleted,
                      onChanged: (bool? value) => _toggleCompletion(todo),
                      activeColor: const Color(0xFF007AFF),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTodo(todo.id),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
