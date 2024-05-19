import 'package:flutter/material.dart';
import 'editScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Category> _categories = [];

  void _addCategory(String title) {
    setState(() {
      _categories.add(Category(title, []));
    });
  }

  void _addTask(String categoryTitle, String taskTitle, String taskLabel) {
    setState(() {
      _categories.firstWhere((cat) => cat.title == categoryTitle).tasks.add(Task(taskTitle, taskLabel));
    });
  }

  void _updateCategory(int index, String newTitle) {
    setState(() {
      _categories[index].title = newTitle;
    });
  }

  void _updateTask(int categoryIndex, int taskIndex, String newTask, String newLabel) {
    setState(() {
      _categories[categoryIndex].tasks[taskIndex].title = newTask;
      _categories[categoryIndex].tasks[taskIndex].label = newLabel;
    });
  }

  void _showAddCategoryDialog() {
    String newCategoryTitle = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm danh mục mới'),
        content: TextField(
          onChanged: (value) {
            newCategoryTitle = value;
          },
          decoration: const InputDecoration(hintText: 'Tên danh mục'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              _addCategory(newCategoryTitle);
              Navigator.of(context).pop();
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(String categoryTitle) {
    String newTaskTitle = '';
    String newTaskLabel = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm công việc mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                newTaskTitle = value;
              },
              decoration: const InputDecoration(hintText: 'Tên công việc'),
            ),
            TextField(
              onChanged: (value) {
                newTaskLabel = value;
              },
              decoration: const InputDecoration(hintText: 'Nhãn'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              _addTask(categoryTitle, newTaskTitle, newTaskLabel);
              Navigator.of(context).pop();
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditScreen(int categoryIndex) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditScreen(
        category: _categories[categoryIndex],
        onCategoryUpdated: (newTitle) {
          _updateCategory(categoryIndex, newTitle);
        },
        onTaskUpdated: (taskIndex, newTask, newLabel) {
          _updateTask(categoryIndex, taskIndex, newTask, newLabel);
        },
      ),
    )).then((value) {
      setState(() {}); // Gọi setState khi quay lại từ EditScreen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách công việc"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ExpansionTile(
            title: Text(category.title),
            children: category.tasks.map((task) => ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  color: task.label == "Quan trọng"
                      ? Colors.red
                      : task.label == "Bình thường"
                      ? Colors.yellow
                      : Colors.black,
                ),
              ),
              subtitle: Text(task.label),
            )).toList(),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditScreen(index);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _showAddTaskDialog(category.title);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Category {
  String title;
  final List<Task> tasks;
  Category(this.title, this.tasks);
}

class Task {
  String title;
  String label;
  Task(this.title, this.label);
}

void main() {
  runApp(const MaterialApp(
    home: MainScreen(),
  ));
}
