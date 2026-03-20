import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/hive_service.dart';

class HomeScreen extends StatelessWidget {
  final HiveService service = HiveService();
  final TextEditingController controller = TextEditingController();

  final VoidCallback toggleTheme;

  HomeScreen({super.key, required this.toggleTheme});

  void showEditDialog(BuildContext context, int index, String oldTitle) {
    TextEditingController editController = TextEditingController(
      text: oldTitle,
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Edit"),
          content: TextField(controller: editController),
          actions: [
            TextButton(
              onPressed: () {
                String text = editController.text.trim();
                if (text.isEmpty) return;

                service.updateTask(index, text);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void showAddDialog(BuildContext context) {
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Add Task"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Task text...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Text(
                      selectedDate == null
                          ? "Select Date"
                          : selectedDate.toString().split(" ")[0],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                String text = controller.text.trim();
                if (text.isEmpty) return;

                service.addTask(text, selectedDate);
                controller.clear();
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box('tasks');

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.dark_mode), onPressed: toggleTheme),
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          var tasks = service.getTasks();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  title: Text(
                    task["title"],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: task["isDone"]
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  subtitle: Text(
                    task["date"] != null
                        ? task["date"].toString().split(" ")[0]
                        : "",
                    style: const TextStyle(fontSize: 12),
                  ),

                  leading: GestureDetector(
                    onTap: () {
                      service.toggleTask(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: task["isDone"]
                            ? Colors.green
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: task["isDone"]
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      service.deleteTask(index);
                    },
                  ),

                  onTap: () {
                    showEditDialog(context, index, task["title"]);
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
