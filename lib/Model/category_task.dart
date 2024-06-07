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
      (json['tasks'] as List<dynamic>)
          .map((taskJson) => Task.fromJson(taskJson))
          .toList(),
    );
  }
}

class Task {
  String title;
  DateTime dateTime;
  String importance;
  bool completed; // Thuộc tính mới cho biết công việc đã hoàn thành hay chưa

  Task(this.title, this.dateTime, this.importance,
      {this.completed = false}); // Thêm tham số mặc định cho completed

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
      completed: json['completed'] ??
          false, // Đảm bảo rằng completed có giá trị mặc định là false nếu không được cung cấp
    );
  }
}
