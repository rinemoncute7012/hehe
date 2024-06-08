import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hehe/Model/category_task.dart';

class StatisticsScreen extends StatefulWidget {
  final List<Category> categories;

  const StatisticsScreen({Key? key, required this.categories}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  DateTime? _selectedDate;
  int? _selectedMonth;
  int? _selectedYear;
  String _filterOption = 'Ngày';
  String _selectedFilterDisplay = 'Ngày';

  @override
  void initState() {
    super.initState();
    _filterOption = 'Ngày'; // Mặc định là Ngày
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thống kê công việc"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Lọc theo:'),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: _filterOption,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _filterOption = value;
                        _showPeriodInputDialog(context);
                      });
                    }
                  },
                  items: <String>['Ngày', 'Tháng', 'Năm'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(width: 8),
                Text(_selectedFilterDisplay), // Hiển thị giá trị đã chọn
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  final category = widget.categories[index];
                  final filteredTasks = _filterTasksByPeriod(category.tasks);
                  int totalTasks = filteredTasks.length;
                  int completedTasks = filteredTasks.where((task) => task.completed).length;
                  int overdueTasks = filteredTasks.where((task) => task.dateTime.isBefore(DateTime.now()) && !task.completed).length;

                  final percentCompleted = totalTasks != 0 ? (completedTasks / totalTasks) * 100 : 0;
                  final percentOverdue = totalTasks != 0 ? (overdueTasks / totalTasks) * 100 : 0;
                  final percentNotCompleted = totalTasks != 0 ? 100 - percentCompleted - percentOverdue : 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${category.title}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: filteredTasks.map((task) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tiêu đề công việc: ${task.title}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "Thời gian đặt lịch: ${DateFormat('yyyy-MM-dd – kk:mm').format(task.dateTime)}",
                                  style: TextStyle(fontSize: 16),
                                ),
                                if (task.completed)
                                  Text(
                                    "Trạng thái: Đã hoàn thành",
                                    style: TextStyle(fontSize: 16),
                                  )
                                else if (task.dateTime.isBefore(DateTime.now()))
                                  Text(
                                    "Trạng thái: Quá hạn",
                                    style: TextStyle(fontSize: 16),
                                  )
                                else
                                  Text(
                                    "Trạng thái: Chưa hoàn thành",
                                    style: TextStyle(fontSize: 16),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Tổng số công việc: $totalTasks",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "Số % công việc đã hoàn thành: ${percentCompleted.toStringAsFixed(2)}%",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "Số % công việc chưa hoàn thành: ${percentNotCompleted.toStringAsFixed(2)}%",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "Số % công việc quá hạn: ${percentOverdue.toStringAsFixed(2)}%",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
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

  void _showPeriodInputDialog(BuildContext context) {
    if (_filterOption == 'Ngày') {
      showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      ).then((selectedDate) {
        if (selectedDate != null) {
          setState(() {
            _selectedDate = selectedDate;
            _selectedMonth = null;
            _selectedYear = null;
            _selectedFilterDisplay = DateFormat('yyyy-MM-dd').format(selectedDate);
          });
        }
      });
    } else if (_filterOption == 'Tháng') {
      _showMonthPicker(context);
    } else if (_filterOption == 'Năm') {
      _showYearPicker(context);
    }
  }

  void _showMonthPicker(BuildContext context) {
    int selectedYear = DateTime.now().year;
    int selectedMonth = DateTime.now().month;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Chọn tháng"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: selectedYear,
                    onChanged: (int? value) {
                      setState(() {
                        selectedYear = value!;
                      });
                    },
                    items: List.generate(100, (index) => DateTime.now().year - index)
                        .map((year) => DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    ))
                        .toList(),
                  ),
                  DropdownButton<int>(
                    value: selectedMonth,
                    onChanged: (int? value) {
                      setState(() {
                        selectedMonth = value!;
                      });
                    },
                    items: List.generate(12, (index) => index + 1)
                        .map((month) => DropdownMenuItem(
                      value: month,
                      child: Text(month.toString()),
                    ))
                        .toList(),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedMonth = selectedMonth;
                  _selectedYear = selectedYear;
                  _selectedDate = null;
                  _selectedFilterDisplay = 'Tháng $selectedMonth, Năm $selectedYear';
                });
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void _showYearPicker(BuildContext context) {
    int selectedYear = DateTime.now().year;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Chọn năm"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<int>(
                value: selectedYear,
                onChanged: (int? value) {
                  setState(() {
                    selectedYear = value!;
                  });
                },
                items: List.generate(100, (index) => DateTime.now().year - index)
                    .map((year) => DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                ))
                    .toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedYear = selectedYear;
                  _selectedDate = null;
                  _selectedMonth = null;
                  _selectedFilterDisplay = 'Năm $selectedYear';
                });
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  List<Task> _filterTasksByPeriod(List<Task> tasks) {
    if (_selectedDate != null) {
      return tasks.where((task) => task.dateTime.year == _selectedDate!.year && task.dateTime.month == _selectedDate!.month && task.dateTime.day == _selectedDate!.day).toList();
    } else if (_selectedMonth != null && _selectedYear != null) {
      return tasks.where((task) => task.dateTime.year == _selectedYear && task.dateTime.month == _selectedMonth).toList();
    } else if (_selectedYear != null) {
      return tasks.where((task) => task.dateTime.year == _selectedYear).toList();
    } else {
      return tasks;
    }
  }
}


