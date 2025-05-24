import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  late var counter = 0;
  String getEmoji(int value) {
    if (value >= 25) return "🤩";
    if (value >= 15) return "😂";
    if (value >= 10) return "😄";
    if (value >= 5) return "🙂";
    return "😐";
  }

  String getQuote(int value) {
    if (value >= 15) return "You're unstoppable!";
    if (value >= 10) return "Keep shining!";
    if (value >= 5) return "You're doing great!";
    return "Every step counts!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      appBar: AppBar(title: Text("MoodMorph"),backgroundColor: Colors.amber,),
      body: Center(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                // border: Border.all(color: Colors.red,),
                color: Colors.amberAccent,
              ),
              margin:EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              width:double.maxFinite,
              child: Column(
                children: [
                  Text(getEmoji(counter),
                    style: TextStyle(
                    fontSize: 100
                  ),),
                  Text(getQuote(counter)),
                  Text("Counter : $counter"),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  alignment: Alignment.bottomRight,
                  onPressed: () {
                    setState(() {
                      counter++;
                    });
                  },
                  icon: const Icon(Icons.add ,size: 100,color: Colors.white,),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      counter = 0;
                    });
                  },
                  icon: const Icon(Icons.refresh,size: 100,color: Colors.black,),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
