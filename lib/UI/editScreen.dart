import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'mainScreen.dart';

class EditScreen extends StatefulWidget {
  final Category category;
  final Function(String) onCategoryUpdated;
  final Function(int, String, DateTime, String) onTaskUpdated; // Cập nhật kiểu tham số truyền vào
  final Function onDeleteCategory;

  const EditScreen({
    Key? key,
    required this.category,
    required this.onCategoryUpdated,
    required this.onTaskUpdated,
    required this.onDeleteCategory,
  }) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late String _categoryTitle;

  @override
  void initState() {
    super.initState();
    _categoryTitle = widget.category.title;
  }

  void _updateTask(int taskIndex, String newTask, DateTime newDateTime, String newImportance) {
    widget.onTaskUpdated(taskIndex, newTask, newDateTime, newImportance);
  }

  void _showEditTaskDialog(int taskIndex) {
    String newTaskTitle = widget.category.tasks[taskIndex].title;
    DateTime selectedDate = widget.category.tasks[taskIndex].dateTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);
    String selectedImportance = widget.category.tasks[taskIndex].importance;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa công việc'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                newTaskTitle = value;
              },
              controller: TextEditingController(text: newTaskTitle),
              decoration: const InputDecoration(hintText: 'Tên công việc'),
            ),
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
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
                  initialTime: selectedTime,
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
              items: ["Quan trọng", "Bình thường", "Không quan trọng"]
                  .map<DropdownMenuItem<String>>((String value) {
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
              if (newTaskTitle.isNotEmpty) {
                final DateTime taskDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                _updateTask(taskIndex, newTaskTitle, taskDateTime, selectedImportance);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa danh mục'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              widget.onDeleteCategory();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                _categoryTitle = value;
              },
              controller: TextEditingController(text: _categoryTitle),
              decoration: const InputDecoration(hintText: 'Tên danh mục'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.category.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.category.tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm').format(task.dateTime)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditTaskDialog(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onCategoryUpdated(_categoryTitle);
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
