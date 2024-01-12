import 'package:example/complete_example/complete_example_page.dart';
import 'package:example/playground/playground_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter customizable calendar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue.shade50,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter customizable calendar'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Playground'),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PlaygroundPage())),
          ),
          ListTile(
            title: const Text('Complete example'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const CompleteExamplePage())),
          ),
        ],
      ),
    );
  }
}
