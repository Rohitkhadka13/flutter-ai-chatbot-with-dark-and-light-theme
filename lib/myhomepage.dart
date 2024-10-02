import 'package:chatapp/message.dart';
import 'package:chatapp/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _message = [
    Message(text: "Hello, I am HEHE GPT. How can I assist you?", isUser: false),
  ];

  @override
  void initState() {
    super.initState();
  }

  callGeminiModel() async {
    try {
      if (_controller.text.isNotEmpty) {
        setState(() {
          _message.add(Message(text: _controller.text, isUser: true));
        });
      }
      final model = GenerativeModel(
          model: "gemini-pro", apiKey: dotenv.env['GOOGLE_API_KEY']!);
      final prompt = _controller.text.trim();
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response != null && response.text != null) {
        setState(() {
          _message.add(Message(text: response.text!, isUser: false));
        });
      } else {
        print("Received null response from AI model");
      }

      _controller.clear();
    } catch (e) {
      print("Error k $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.read(themeProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset("assets/gpt-robot.png"),
                const SizedBox(width: 10),
                Text(
                  "HEHE Gpt",
                  style: Theme.of(context).textTheme.titleLarge,
                )
              ],
            ),
            GestureDetector(
                onTap: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                child: currentTheme == ThemeMode.dark
                    ? Icon(Icons.light_mode)
                    : Icon(Icons.dark_mode))
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _message.length,
              itemBuilder: (context, index) {
                final message = _message[index];
                return ListTile(
                  title: Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        borderRadius: message.isUser
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              )
                            : const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                      ),
                      child: Text(
                        message.text,
                        style: message.isUser
                            ? Theme.of(context).textTheme.bodyMedium
                            : Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                bottom: 32.0, top: 16, left: 16, right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: Theme.of(context).textTheme.titleSmall,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: callGeminiModel,
                      child: Image.asset("assets/send.png"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
