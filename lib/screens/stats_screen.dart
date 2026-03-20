import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var box = Hive.box('tasks');
    var tasks = box.values.toList();

    int total = tasks.length;
    int completed = tasks.where((t) => t["isDone"] == true).length;
    int pending = total - completed;

    double percent = total == 0 ? 0 : (completed / total);

    return Scaffold(
      appBar: AppBar(title: const Text("📊 Statistics")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade300,
              ),
              child: FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.green,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text("Total task: $total"),
            Text("Completed: $completed"),
            Text("Pending: $pending"),

            const SizedBox(height: 40),

            Text(
              "% ${(percent * 100).toStringAsFixed(1)} completed",
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
