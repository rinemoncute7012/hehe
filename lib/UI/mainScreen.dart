import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'editScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Category> _categories = [];
  final List<String> _labels = ["Quan trọng", "Bình thường", "Không quan trọng"];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _showDeleteConfirmationDialog(BuildContext context, Function onConfirmed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa công việc này không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              onConfirmed();
              Navigator.of(context).pop();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? categoriesString = prefs.getString('categories');
    if (categoriesString != null) {
      final List<dynamic> categoriesJson = json.decode(categoriesString);
      setState(() {
        _categories.clear();
        for (var categoryJson in categoriesJson) {
          _categories.add(Category.fromJson(categoryJson));
        }
      });
    }
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String categoriesString = json.encode(_categories);
    prefs.setString('categories', categoriesString);
  }

  void _addCategory(String title) {
    setState(() {
      _categories.add(Category(title, []));
    });
    _saveData();
  }

  void _addTask(String categoryTitle, String taskTitle, DateTime taskDateTime, String importance) {
    setState(() {
      _categories.firstWhere((cat) => cat.title == categoryTitle).tasks.add(
        Task(taskTitle, taskDateTime, importance, completed: false), // Thêm thuộc tính completed với giá trị mặc định là false
      );
    });
    _saveData();
  }

  void _updateCategory(int index, String newTitle) {
    setState(() {
      _categories[index].title = newTitle;
    });
    _saveData();
  }

  void _updateTask(int categoryIndex, int taskIndex, String newTask, DateTime newDateTime, String newImportance) {
    setState(() {
      _categories[categoryIndex].tasks[taskIndex].title = newTask;
      _categories[categoryIndex].tasks[taskIndex].dateTime = newDateTime;
      _categories[categoryIndex].tasks[taskIndex].importance = newImportance;
    });
    _saveData();
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
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String selectedImportance = _labels[0];

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
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: const Text('Chọn ngày'),
            ),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                }
              },
              child: const Text('Chọn giờ'),
            ),
            DropdownButton<String>(
              value: selectedImportance,
              onChanged: (String? newValue) {
                setState(() {
                  selectedImportance = newValue!;
                });
              },
              items: _labels.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
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
              if (newTaskTitle.isNotEmpty && selectedDate != null && selectedTime != null) {
                final DateTime taskDateTime = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );
                _addTask(categoryTitle, newTaskTitle, taskDateTime, selectedImportance);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(int categoryIndex) {
    setState(() {
      _categories.removeAt(categoryIndex);
    });
    _saveData();
  }

  void _showEditScreen(int categoryIndex) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EditScreen(
        category: _categories[categoryIndex],
        onCategoryUpdated: (newTitle) {
      _updateCategory(categoryIndex, newTitle);
    },
    onTaskUpdated: (taskIndex, newTask, newDateTime, newImportance) {
    _updateTask(categoryIndex, taskIndex, newTask, newDateTime,
        newImportance);
    },
          onDeleteCategory: () {
            _deleteCategory(categoryIndex);
          },
        ),
    )).then((value) {
      setState(() {
        _categories[categoryIndex] = value as Category;
      });
      _saveData();
    });
  }

  Color getColorForImportance(String importance) {
    switch (importance) {
      case "Quan trọng":
        return Colors.red;
      case "Bình thường":
        return Colors.yellow;
      case "Không quan trọng":
        return Colors.green;
      default:
        return Colors.black;
    }
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
            children: category.tasks
                .asMap()
                .entries
                .map((entry) => Dismissible(
              key: Key(entry.value.title),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16.0),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                _showDeleteConfirmationDialog(context, () {
                  setState(() {
                    category.tasks.removeAt(entry.key);
                  });
                  _saveData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa công việc'),
                      action: SnackBarAction(
                        label: 'Hoàn tác',
                        onPressed: () {
                          setState(() {
                            category.tasks.insert(entry.key, entry.value);
                          });
                          _saveData();
                        },
                      ),
                    ),
                  );
                });
              },
              child: ListTile(
                title: Text(
                  entry.value.title,
                  style: TextStyle(
                    color: getColorForImportance(entry.value.importance),
                    fontWeight: entry.value.importance == "Bình thường"
                        ? FontWeight.bold
                        : null,
                  ),
                ),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd – kk:mm').format(entry.value.dateTime),
                  style: TextStyle(
                    color: getColorForImportance(entry.value.importance),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    entry.value.completed ? Icons.check_box : Icons.check_box_outline_blank,
                    color: entry.value.completed ? Colors.green : null,
                  ),
                  onPressed: () {
                    setState(() {
                      entry.value.completed = !entry.value.completed;
                    });
                    _saveData();
                  },
                ),
              ),
            ))
                .toList(),
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

  Map<String, dynamic> toJson() => {
    'title': title,
    'tasks': tasks.map((task) => task.toJson()).toList(),
  };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      json['title'],
      (json['tasks'] as List<dynamic>).map((taskJson) => Task.fromJson(taskJson)).toList(),
    );
  }
}

class Task {
  String title;
  DateTime dateTime;
  String importance;
  bool completed; // Thuộc tính mới cho biết công việc đã hoàn thành hay chưa

  Task(this.title, this.dateTime, this.importance, {this.completed = false}); // Thêm tham số mặc định cho completed

  Map<String, dynamic> toJson() => {
    'title': title,
    'dateTime': dateTime.toIso8601String(),
    'importance': importance,
    'completed': completed, // Thêm completed vào dữ liệu JSON
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      json['title'],
      DateTime.parse(json['dateTime']),
      json['importance'],
      completed: json['completed'] ?? false, // Đảm bảo rằng completed có giá trị mặc định là false nếu không được cung cấp
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MainScreen(),
  ));
}
