import 'package:attendance_tracker/models/task.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import '../main.dart';
import '../widgets/dialogs.dart';
import '../widgets/main_drawer.dart';
import '../widgets/task_widget.dart';
import 'add_task_screen.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  bool isDrawerOpen = false;
  GlobalKey<SliderDrawerState> drawerKey = GlobalKey<SliderDrawerState>();

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  void onDrawerToggle() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      if (isDrawerOpen) {
        animationController.forward();
        drawerKey.currentState!.openSlider();
      } else {
        animationController.reverse();
        drawerKey.currentState!.closeSlider();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final base = BaseWidget.of(context);

    return ValueListenableBuilder(
        valueListenable: base.dataStore.listenToTask(),
        builder: (ctx, Box<Task> box, Widget? child) {
          var tasks = box.values.toList();
          tasks.sort((a, b) => a.createdAtDate.compareTo(b.createdAtDate));

          return Scaffold(
            backgroundColor: Colors.white,
            body: SliderDrawer(
              key: drawerKey,
              isDraggable: false,
              animationDuration: 1000,
              appBar: AppBar(
                leading: IconButton(
                  onPressed: onDrawerToggle,
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: animationController,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Text(
                  'My Tasks',
                  style:
                      TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => const AddTaskScreen(task: null))),
                    icon: const Icon(Icons.add),
                    tooltip: 'Add tasks',
                  )
                ],
              ),
              slider: const MainDrawer(),
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No task to do!',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Lottie.asset('assets/lottie/checklist.json'),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: mq.width * .03,
                          vertical: mq.height * .005),
                      child: ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          var task = tasks[index];

                          return Dismissible(
                              key: Key(task.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) {
                                base.dataStore.deleteTask(task: task);
                                Dialogs.showSnackBar(
                                    context, 'Task deleted successfully!');
                              },
                              background: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                padding: const EdgeInsets.only(right: 20),
                                alignment: Alignment.centerRight,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 4,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: TaskWidget(task: task));
                        },
                      ),
                    ),
            ),
          );
        });
  }
}
