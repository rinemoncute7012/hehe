// Các import cần thiết cho ứng dụng
import 'dart:convert'; // Để sử dụng mã hóa và giải mã JSON
import 'package:flutter/material.dart'; // Thư viện chính cho Flutter
import 'package:hehe/UI/statistical.dart';
import 'package:hehe/services/setting_notifications.dart'; // Import dịch vụ thông báo tùy chỉnh
import 'package:intl/intl.dart'; // Để định dạng ngày và giờ
import 'package:shared_preferences/shared_preferences.dart'; // Để lưu trữ dữ liệu trên thiết bị
import 'package:hehe/Model/category_task.dart'; // Import model Category và Task từ file khác
import 'editScreen.dart'; // Import màn hình chỉnh sửa

// Khai báo widget chính của ứng dụng
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// Trạng thái của widget chính
class _MainScreenState extends State<MainScreen> {
  // Danh sách các danh mục công việc
  final List<Category> _categories = [];

  // Các nhãn mức độ quan trọng của công việc
  final List<String> _labels = ["Quan trọng", "Bình thường", "Không quan trọng"];

  // Dịch vụ thông báo
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();

    // Khởi tạo thông báo khi widget được xây dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        print('Đang khởi tạo thông báo...');
        await _notificationService.initialize(); // Khởi tạo dịch vụ thông báo
        print('Khởi tạo thông báo thành công');
      } catch (e) {
        print('Error initializing notifications: $e');
      }
    });

    // Tải dữ liệu từ SharedPreferences khi khởi động ứng dụng
    _loadData();
  }

  // Hàm đếm số công việc đã hoàn thành trong một danh mục
  int _countCompletedTasks(Category category) {
    return category.tasks.where((task) => task.completed).length;
  }

  // Hiển thị hộp thoại xác nhận xóa
  void _showDeleteConfirmationDialog(BuildContext context, Function onConfirmed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa công việc này không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại khi bấm "Hủy"
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              onConfirmed(); // Thực hiện hành động xóa khi bấm "Xóa"
              Navigator.of(context).pop(); // Đóng hộp thoại
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // Hàm tải dữ liệu từ SharedPreferences
  void _loadData() async {
    final prefs = await SharedPreferences.getInstance(); // Lấy đối tượng SharedPreferences
    final String? categoriesString = prefs.getString('categories'); // Lấy chuỗi JSON từ SharedPreferences
    if (categoriesString != null) {
      final List<dynamic> categoriesJson = json.decode(categoriesString); // Giải mã chuỗi JSON thành danh sách
      setState(() {
        _categories.clear(); // Xóa danh sách hiện tại
        for (var categoryJson in categoriesJson) {
          _categories.add(Category.fromJson(categoryJson)); // Thêm các danh mục vào danh sách
        }
      });
    }
  }

  // Hàm lưu dữ liệu vào SharedPreferences
  void _saveData() async {
    final prefs = await SharedPreferences.getInstance(); // Lấy đối tượng SharedPreferences
    final String categoriesString = json.encode(_categories); // Mã hóa danh sách thành chuỗi JSON
    prefs.setString('categories', categoriesString); // Lưu chuỗi JSON vào SharedPreferences
  }

  // Hàm thêm một danh mục mới
  void _addCategory(String title) {
    setState(() {
      _categories.add(Category(title, [])); // Thêm danh mục vào danh sách
    });
    _saveData(); // Lưu dữ liệu sau khi thêm
  }

  // Hàm thêm một công việc mới vào danh mục
  void _addTask(String categoryTitle, String taskTitle, DateTime taskDateTime, String importance) {
    setState(() {
      _categories.firstWhere((cat) => cat.title == categoryTitle).tasks.add(
        Task(taskTitle, taskDateTime, importance, completed: false),
      );
    });
    _saveData(); // Lưu dữ liệu sau khi thêm

    // Lên lịch thông báo cho công việc mới
    final int taskId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    print('Đang lên lịch thông báo cho công việc: $taskTitle vào ${DateFormat('yyyy-MM-dd – kk:mm').format(taskDateTime)}');
    _notificationService.scheduleNotification(
      taskId,
      taskTitle,
      'Thời gian: ${DateFormat('yyyy-MM-dd – kk:mm').format(taskDateTime)}',
      taskDateTime,
    );
    _notificationService.schedulePreNotifications(
      taskId,
      taskTitle,
      'Thời gian: ${DateFormat('yyyy-MM-dd – kk:mm').format(taskDateTime)}',
      taskDateTime,
    );
    print('Đã lên lịch thông báo cho công việc: $taskTitle vào ${DateFormat('yyyy-MM-dd – kk:mm').format(taskDateTime)}');
  }

  // Hàm cập nhật tiêu đề của một danh mục
  void _updateCategory(int index, String newTitle) {
    setState(() {
      _categories[index].title = newTitle; // Cập nhật tiêu đề
    });
    _saveData(); // Lưu dữ liệu sau khi cập nhật
  }

  // Hàm cập nhật thông tin của một công việc
  void _updateTask(int categoryIndex, int taskIndex, String newTask, DateTime newDateTime, String newImportance) {
    setState(() {
      _categories[categoryIndex].tasks[taskIndex].title = newTask; // Cập nhật tiêu đề công việc
      _categories[categoryIndex].tasks[taskIndex].dateTime = newDateTime; // Cập nhật ngày giờ công việc
      _categories[categoryIndex].tasks[taskIndex].importance = newImportance; // Cập nhật mức độ quan trọng
    });
    _saveData(); // Lưu dữ liệu sau khi cập nhật

    // Lên lịch thông báo cho công việc đã cập nhật
    final Task updatedTask = _categories[categoryIndex].tasks[taskIndex];
    final int taskId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    print('Đang lên lịch thông báo cho công việc đã cập nhật: ${updatedTask.title}');
    _notificationService.scheduleNotification(
      taskId,
      updatedTask.title,
      'Thời gian: ${DateFormat('yyyy-MM-dd – kk:mm').format(updatedTask.dateTime)}',
      updatedTask.dateTime,
    );
    _notificationService.schedulePreNotifications(
      taskId,
      updatedTask.title,
      'Thời gian: ${DateFormat('yyyy-MM-dd – kk:mm').format(updatedTask.dateTime)}',
      updatedTask.dateTime,
    );
  }

  // Hàm hiển thị hộp thoại thêm danh mục mới
  void _showAddCategoryDialog() {
    String newCategoryTitle = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm danh mục mới'),
        content: TextField(
          onChanged: (value) {
            newCategoryTitle = value; // Lấy giá trị nhập vào
          },
          decoration: const InputDecoration(hintText: 'Tên danh mục'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại khi bấm "Hủy"
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              _addCategory(newCategoryTitle); // Thêm danh mục mới khi bấm "Thêm"
              Navigator.of(context).pop(); // Đóng hộp thoại
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  // Hàm hiển thị hộp thoại thêm công việc mới
  void _showAddTaskDialog(String categoryTitle) {
    String newTaskTitle = '';
    DateTime? selectedDate; // Biến lưu ngày được chọn
    TimeOfDay? selectedTime; // Biến lưu giờ được chọn
    String selectedImportance = _labels[0]; // Mức độ quan trọng mặc định

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Thêm công việc mới'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      newTaskTitle = value; // Lấy tiêu đề công việc từ người dùng
                    },
                    decoration: const InputDecoration(hintText: 'Tên công việc'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date; // Lấy ngày được chọn
                        });
                      }
                    },
                    child: Text(
                      selectedDate == null ? 'Chọn ngày' : 'Ngày: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          selectedTime = time; // Lấy giờ được chọn
                        });
                      }
                    },
                    child: Text(
                      selectedTime == null ? 'Chọn giờ' : 'Giờ: ${selectedTime!.format(context)}',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedImportance,
                    items: _labels.map((label) {
                      return DropdownMenuItem(
                        value: label,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedImportance = value!; // Lấy mức độ quan trọng được chọn
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng hộp thoại khi bấm "Hủy"
                  },
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    if (newTaskTitle.isNotEmpty && selectedDate != null && selectedTime != null) {
                      final taskDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime!.hour,
                        selectedTime!.minute,
                      );
                      _addTask(categoryTitle, newTaskTitle, taskDateTime, selectedImportance); // Thêm công việc mới
                      Navigator.of(context).pop(); // Đóng hộp thoại
                    }
                  },
                  child: const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Hàm xóa một danh mục
  void _deleteCategory(int categoryIndex) {
    setState(() {
      _categories.removeAt(categoryIndex); // Xóa danh mục tại vị trí chỉ định
    });
    _saveData(); // Lưu dữ liệu sau khi xóa
  }

  // Hàm hiển thị màn hình chỉnh sửa danh mục và công việc
  void _showEditScreen(int categoryIndex) {
    if (_categories.isNotEmpty && categoryIndex >= 0 && categoryIndex < _categories.length) {
      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (context) => EditScreen(
          category: _categories[categoryIndex], // Truyền danh mục hiện tại sang màn hình chỉnh sửa
          onCategoryUpdated: (newTitle) {
            _updateCategory(categoryIndex, newTitle); // Cập nhật tiêu đề danh mục
          },
          onTaskUpdated: (taskIndex, newTask, newDateTime, newImportance) {
            _updateTask(categoryIndex, taskIndex, newTask, newDateTime, newImportance); // Cập nhật thông tin công việc
          },
          onDeleteCategory: () {
            _deleteCategory(categoryIndex); // Xóa danh mục
          },
        ),
      ))
          .then((value) {
        setState(() {
          _categories[categoryIndex] = value as Category; // Cập nhật danh mục sau khi chỉnh sửa
        });
        _saveData(); // Lưu dữ liệu sau khi chỉnh sửa
      });
    }
  }

  // Hàm đặt màu sắc cho mức độ quan trọng của công việc
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
        actions: [
          IconButton(onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context)
            => StatisticsScreen(categories: _categories,)
            ),);
          }, icon: Icon(Icons.stacked_bar_chart))
          
        ],
      ),
      body: ListView.builder(
        itemCount: _categories.length, // Số lượng danh mục
        itemBuilder: (context, index) {
          final category = _categories[index]; // Lấy danh mục tại vị trí hiện tại
          final completedTasks = _countCompletedTasks(category); // Số công việc đã hoàn thành
          final totalTasks = category.tasks.length; // Tổng số công việc
          String completionStatus = '';

          // Xác định trạng thái hoàn thành của danh mục
          if (completedTasks == 0) {
            completionStatus = '(chưa làm)';
          } else if (completedTasks > 0 && completedTasks <= totalTasks ~/ 3) {
            completionStatus = '(lười biếng)';
          } else if (completedTasks > totalTasks ~/ 3 && completedTasks <= totalTasks * 2 / 3) {
            completionStatus = '(khá tốt)';
          } else if (completedTasks == totalTasks) {
            completionStatus = '(hoàn thành)';
          }

          return ExpansionTile(
            title: Row(
              children: [
                Text(category.title), // Tiêu đề danh mục
                SizedBox(width: 10),
                Text(
                  '$completedTasks/$totalTasks $completionStatus',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
                    category.tasks.removeAt(entry.key); // Xóa công việc
                  });
                  _saveData(); // Lưu dữ liệu sau khi xóa
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đã xóa công việc'),
                      action: SnackBarAction(
                        label: 'Hoàn tác',
                        onPressed: () {
                          setState(() {
                            category.tasks.insert(entry.key, entry.value); // Hoàn tác xóa
                          });
                          _saveData(); // Lưu dữ liệu sau khi hoàn tác
                        },
                      ),
                    ),
                  );
                });
              },
              child: ListTile(
                title: Text(
                  entry.value.title, // Tiêu đề công việc
                  style: TextStyle(
                    color: getColorForImportance(entry.value.importance), // Màu sắc dựa trên mức độ quan trọng
                    fontWeight: entry.value.importance == "Bình thường" ? FontWeight.bold : null,
                  ),
                ),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd – kk:mm').format(entry.value.dateTime), // Ngày giờ công việc
                  style: TextStyle(
                    color: getColorForImportance(entry.value.importance), // Màu sắc dựa trên mức độ quan trọng
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    entry.value.completed ? Icons.check_box : Icons.check_box_outline_blank, // Biểu tượng hoàn thành
                    color: entry.value.completed ? Colors.green : null,
                  ),
                  onPressed: () {
                    setState(() {
                      entry.value.completed = !entry.value.completed; // Đổi trạng thái hoàn thành
                    });
                    _saveData(); // Lưu dữ liệu sau khi thay đổi
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
                    _showEditScreen(index); // Chỉnh sửa danh mục
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _showAddTaskDialog(category.title); // Thêm công việc mới
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog, // Thêm danh mục mới
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Hàm main khởi động ứng dụng
void main() {
  runApp(const MaterialApp(
    home: MainScreen(),
  ));
}
