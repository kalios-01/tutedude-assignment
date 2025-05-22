import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.cyan[200],
      appBar: AppBar(title: Text("Image App",style: TextStyle(
        fontSize: 24,
        color: Colors.white,
        fontWeight: FontWeight.bold
      ),), backgroundColor: Colors.cyan[800],),
      body: Center(
        child: Column(
          children: [
            Text("Image From Assets",style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w400
            ),),
            Container(
              height: 150,
              width: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white ,width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(2, 4),
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Image(image:
              AssetImage("assets/image.jpeg"),
                fit: BoxFit.fitWidth,
              ),
            ),
            Text("Image From Network",style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.w400
            ),),
            Container(
              height: 200,
              width: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white,width: 4),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Image(image:
              NetworkImage("https://images.pexels.com/photos/209726/pexels-photo-209726.jpeg"),
                fit: BoxFit.fill,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: Icon(Icons.error, color: Colors.red, size: 40),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




