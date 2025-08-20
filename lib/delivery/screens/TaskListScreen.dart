import 'package:flutter/material.dart';
import 'TaskDetailScreen.dart';
import 'PreDeliveryScanScreen.dart';

// 简单数据模型
class Module {
  final String name;
  final String code;
  const Module({required this.name, required this.code});
}

class TaskItem {
  final String id;
  final String address;
  final String timeWindow;
  final String contactName;
  final List<Module> modules;

  const TaskItem({
    required this.id,
    required this.address,
    required this.timeWindow,
    required this.contactName,
    required this.modules,
  });
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // 示例任务数据（与截图一致）
  final List<TaskItem> tasks = const [
    TaskItem(
      id: '74649349',
      address:
          'CHANGI HYPER BUSINESS PK #2-11 8 8 Changi Business Park Ave 1\nSingapore 486018',
      timeWindow: '8:00 AM — 10:00 AM',
      contactName: 'LinksPoints Test DC Customer',
      modules: [
        Module(name: 'ZBK-B', code: '74649349,ZBK-B-01'),
        Module(name: 'ZGN-A', code: '74649349,ZGN-A-01'),
        Module(name: 'ZGN-W', code: '74649349,ZGN-W-01'),
      ],
    ),
    TaskItem(
      id: '74649427',
      address:
          'CHANGI HYPER BUSINESS PK #8-158 8, 8 Changi Bus\nSingapore 486018',
      timeWindow: '8:00 AM — 10:00 AM',
      contactName: 'LinksPoints Test DC Customer',
      modules: [
        Module(name: 'ZBK-B', code: '74649427,ZBK-B-01'),
        Module(name: 'ZGN-A', code: '74649427,ZGN-A-01'),
      ],
    ),
  ];

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALL JOBS'),
        leading: const BackButton(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.menu, color: Colors.black54),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Column(
            children: [
              Container(
                height: 4,
                color: Colors.lightBlue,
                alignment: Alignment.center,
                child: const Text('2',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              SizedBox(
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _TabChip(label: 'IN TRANSIT', count: 2, selected: true),
                    _TabChip(label: 'EXCEPTION', count: 0),
                    _TabChip(label: 'COMPLETED', count: 0),
                    _TabChip(label: 'ALL', count: 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final t = tasks[index];
          final selected = selectedIndex == index;
          return InkWell(
            onTap: () => setState(() => selectedIndex = index),
            child: Container(
              color: selected ? Colors.blue.shade50 : null,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _NumberPill(number: (index + 1).toString()),
                    const SizedBox(width: 8),
                    const _DeliveryTag(),
                    const SizedBox(width: 8),
                    Text(t.id,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    t.address,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        t.timeWindow,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          if (selectedIndex == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('请选择一个任务再点击 Proceed')),
            );
            return;
          }
          final selectedTask = tasks[selectedIndex!];
          // 跳转到 TaskDetailScreen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  TaskDetailScreen(task: selectedTask, allTasks: tasks),
            ),
          );
        },
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  const _TabChip(
      {required this.label,
      required this.count,
      this.selected = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.lightBlue : Colors.black54;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text('(${count})', style: TextStyle(color: color)),
        const SizedBox(height: 4),
        Container(
            height: 3, width: 56, color: selected ? color : Colors.transparent),
      ],
    );
  }
}

class _NumberPill extends StatelessWidget {
  final String number;
  const _NumberPill({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(number,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

class _DeliveryTag extends StatelessWidget {
  const _DeliveryTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.lightBlue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'DELIVERY',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
    );
  }
}
