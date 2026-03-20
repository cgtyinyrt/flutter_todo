import 'package:hive/hive.dart';

class HiveService {
  final box = Hive.box('tasks');

  void addTask(String title, DateTime? date) {
    if (title.trim().isEmpty) return;

    box.add({"title": title, "isDone": false, "date": date?.toString()});
  }

  List getTasks() {
    return box.values.toList();
  }

  void toggleTask(int index) {
    var task = box.getAt(index);
    task["isDone"] = !task["isDone"];
    box.putAt(index, task);
  }

  void updateTask(int index, String newTitle) {
    if (newTitle.trim().isEmpty) return;

    var task = box.getAt(index);
    task["title"] = newTitle;
    box.putAt(index, task);
  }

  void deleteTask(int index) {
    box.deleteAt(index);
  }
}
