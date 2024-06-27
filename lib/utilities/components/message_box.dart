import 'package:chatmod/model/messages.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class MessageBox extends StatelessWidget {
  Message message;
  MessageBox({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return message.isUser
        ? Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                // color: Color.fromARGB(255, 36, 58, 122),
                color: Color.fromARGB(151, 70, 76, 82),
                // color: Color.fromRGBO(160, 21, 67, 0.822),
                // color: Color(0xff1A1F24),

                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  topLeft: Radius.circular(20),
                )),
            child: Text(
              message.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser) // If message is from chatbot
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.transparent,
                  child: Lottie.asset(
                    'assets/geminiLogo2.json',
                    fit: BoxFit.contain,
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xff4D9489F5),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      color: Color(0x33000000),
                      offset: Offset(
                        0,
                        1,
                      ),
                    )
                  ],
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: Color(0xff9489F5),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
  }
}
