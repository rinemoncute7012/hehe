import 'package:flutter/material.dart';
import 'mainScreen.dart';

class EditScreen extends StatefulWidget {
  final Category category;
  final Function(String) onCategoryUpdated;
  final Function(int, String, String) onTaskUpdated; // Thêm tham số cho nhãn

  const EditScreen({
    required this.category,
    required this.onCategoryUpdated,
    required this.onTaskUpdated,
    Key? key,
  }) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _categoryController;
  late List<TextEditingController> _taskControllers;
  late String _selectedLabel; // Thêm biến chứa nhãn được chọn

  List<String> _labels = ["Quan trọng", "Bình thường", "Không quan trọng"]; // Danh sách các nhãn có sẵn

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.category.title);
    _taskControllers = widget.category.tasks
        .map((task) => TextEditingController(text: task.title))
        .toList();
    _selectedLabel = _labels[0]; // Mặc định chọn nhãn đầu tiên
  }

  @override
  void dispose() {
    _categoryController.dispose();
    for (var controller in _taskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveCategory() {
    widget.onCategoryUpdated(_categoryController.text);
    for (int i = 0; i < _taskControllers.length; i++) {
      widget.onTaskUpdated(i, _taskControllers[i].text, _selectedLabel); // Thêm nhãn vào tham số truyền vào
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa danh mục và công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCategory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Tên danh mục'),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>( // Thêm DropdownButton để chọn nhãn
              value: _selectedLabel,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLabel = newValue!;
                });
              },
              items: _labels.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _taskControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: _taskControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Công việc ${index + 1}',
                        // Thay đổi màu sắc dựa trên nhãn được chọn
                        fillColor: _selectedLabel == "Quan trọng"
                            ? Colors.red
                            : _selectedLabel == "Bình thường"
                            ? Colors.yellow
                            : Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
