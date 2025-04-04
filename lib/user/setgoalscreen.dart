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
    }
  }

  void _toggleCompletion(Todo todo) async {
    await _firestore.collection('todos').doc(todo.id).update({'isCompleted': !todo.isCompleted});
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
      appBar: AppBar(
        title: Text("To-Do List", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _todoController,
              decoration: InputDecoration(
                labelText: "Enter your task",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _selectedDate == null
                      ? "Select due date"
                      : DateFormat.yMd().format(_selectedDate!),
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _addTodo,
              child: Text("Add Task"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700],foregroundColor: Colors.white),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('todos')
                    .where('userId', isEqualTo: userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  
                  List<Todo> todos = snapshot.data!.docs.map((doc) {
                    return Todo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                  }).toList();
                  
                  List<Todo> activeTodos = todos.where((t) => !t.isCompleted).toList();
                  List<Todo> completedTodos = todos.where((t) => t.isCompleted).toList();
                  
                  return ListView(
                    children: [
                      _buildTodoSection("Upcoming Tasks", activeTodos),
                      if (completedTodos.isNotEmpty) _buildTodoSection("Completed Tasks", completedTodos),
                    ],
                  );
                },
              ),
            ),
          ],
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
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return Card(
              color: Colors.grey[800],
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  todo.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                subtitle: Text("Due: ${DateFormat.yMd().add_jm().format(todo.dueDate)}", style: TextStyle(color: Colors.grey[400])),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: todo.isCompleted,
                      onChanged: (bool? value) => _toggleCompletion(todo),
                      activeColor: Colors.white,
                      checkColor: Colors.green,
                      side: BorderSide(color: Colors.white),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
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
