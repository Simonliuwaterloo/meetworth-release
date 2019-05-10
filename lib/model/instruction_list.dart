import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
class InstructionList{
  List<String> instructions;

  InstructionList(List<String> instructions) {
    this.instructions = instructions;
  }

  Widget createList() {
    if (this.instructions == null) return Container();
    return ListView.builder(
      itemCount: this.instructions.length,
      itemBuilder: (BuildContext context, int index) {
        return new Card(
          child: Html(
            data: "<p>${instructions[index]}<p>",
            defaultTextStyle: TextStyle(
              fontSize: 30,
            ),
          ),
        );
      },
    );
  }
}