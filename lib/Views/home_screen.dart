import 'dart:io';
import 'package:chatmod/model/messages.dart';
import 'package:chatmod/utilities/components/message_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Gemini gemini = Gemini.instance;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> messages = [
    Message(text: "Hello", isUser: true),
    Message(text: "Hii", isUser: false),
    Message(text: "How are you", isUser: true),
    Message(text: "I am fine, what about you?", isUser: false),
  ];
  XFile? _selectedImage;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xff1e0b74),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "CHATMOD",
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xff1e0b74),
              Color(0xff2b0d8b),
              Color(0xff120554),
              Color(0xff01092d),
            ],
            stops: [
              0.3,
              0.55,
              0.78,
              1.0,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                reverse: true,
                itemBuilder: (context, index) {
                  Message message = messages[messages.length - 1 - index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Align(
                      alignment: message.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (message.image != null)
                              Align(
                                alignment: Alignment.topRight,
                                child: Image.file(
                                  File(message.image!),
                                  height: 150,
                                  width: 150,
                                ),
                              ),
                            MessageBox(message: message),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_selectedImage != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.file(
                    File(_selectedImage!.path),
                    height: 80,
                    width: 80,
                  ),
                ),
              ),
            // User input
            Padding(
              padding: const EdgeInsets.all(17.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.grey)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Write your message",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        _sendMedia();
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Color(0xff9489F5),
                      ),
                    ),
                    _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeAlign: BorderSide.strokeAlignCenter,
                                color: Color(0xff9489F5),
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              if (_controller.text.isNotEmpty) {
                                _sendMessage(Message(
                                  text: _controller.text,
                                  isUser: true,
                                  image: _selectedImage?.path,
                                ));
                                _controller.clear();
                                setState(() {
                                  _selectedImage = null;
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.send,
                              color: Color(0xff9489F5),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//functions
  void _sendMessage(Message chatMessage) {
    setState(() {
      messages.add(chatMessage);
      _isLoading = true;
    });
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    try {
      List<Uint8List>? images;
      String question = chatMessage.text;
      if (chatMessage.image?.isNotEmpty ?? false) {
        images = [File(chatMessage.image!).readAsBytesSync()];
      }
      StringBuffer responseBuffer = StringBuffer();
      gemini.streamGenerateContent(question, images: images).listen((event) {
        responseBuffer
            .write(event.content?.parts?.map((e) => e.text).join(' ') ?? '');
      }).onDone(() {
        String response = responseBuffer.toString();
        Message message =
            Message(isUser: false, text: response.replaceAll("*", ""));
        setState(() {
          messages.add(message);
          _isLoading = false;
        });
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      const CircularProgressIndicator();
    }
  }

  void _sendMedia() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedImage = file;
      });
    }
  }
}
