import 'package:flutter/material.dart';
import '../tools/text_tools/text_tools_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toolspace'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Tools',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _tools.length,
                itemBuilder: (context, index) {
                  final tool = _tools[index];
                  return _ToolCard(
                    tool: tool,
                    onTap: () => _navigateToTool(context, tool),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTool(BuildContext context, Tool tool) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => tool.screen,
      ),
    );
  }

  static final List<Tool> _tools = [
    Tool(
      id: 'text-tools',
      name: 'Text Tools',
      description: 'Case conversion, cleaning, JSON formatting, and more',
      icon: Icons.text_fields,
      screen: const TextToolsScreen(),
      color: Colors.blue,
    ),
    // Future tools will be added here
  ];
}

class Tool {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Widget screen;
  final Color color;

  const Tool({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.screen,
    required this.color,
  });
}

class _ToolCard extends StatelessWidget {
  final Tool tool;
  final VoidCallback onTap;

  const _ToolCard({
    required this.tool,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    tool.icon,
                    size: 32,
                    color: tool.color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tool.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                tool.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
