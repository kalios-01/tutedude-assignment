import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A237E), // Deep indigo background
      appBar: AppBar(
        title: Text("CardConnect", style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400),),
        backgroundColor: Color(0xFF303F9F), // Slightly lighter indigo for app bar
        elevation: 0,
      ),
      body: Container(
        width: double.maxFinite,
        height: 210,
        decoration: BoxDecoration(
          color: Colors.white, // White background for card
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(16),
        child: Column(
            children:
        [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.call),
              Text("7069916002")],), //number
          Row(
            children: [
              Container(height: 100,width: 120,
                  decoration: BoxDecoration(
                    color: Color(0xFFE8EAF6), // Light indigo tint for avatar background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: EdgeInsets.all(8),
                  child: Image(image: AssetImage('assets/avatar.png'),
                  )
              ),// avatar
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Row(
                    children:[
                      Icon(Icons.person , size: 30,),
                      Text("Priyanshu Yadav",style: TextStyle(fontWeight: FontWeight.bold

                      ),)],),
                  Row(
                    children:[
                      Icon(Icons.developer_board,size: 30,),
                      Text("Flutter-Developer",style: TextStyle(fontWeight: FontWeight.bold))],),
                  Row(
                    children:[
                      Icon(Icons.location_city,size: 30,),
                      Text("Vapi,Gujarat",style: TextStyle(fontWeight: FontWeight.bold))],),
                ],

              ) // info
            ],),
          Row(
            children: [
              Container(
                color: Color(0xFFE0E0E0), // Light grey for divider
                height: 4,
                width: 370,
              )
            ],

          ), //line Breaker

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
              children: [
                Icon(Icons.web, color: Color(0xFF303F9F)), // Indigo for icons
                Text("www.kaliostech.com", style: TextStyle(color: Color(0xFF303F9F)))
              ],
            ),
              Column(
              children: [
                Icon(Icons.email, color: Color(0xFF303F9F)), // Indigo for icons
                Text("priyanshu@kaliostech.com", style: TextStyle(color: Color(0xFF303F9F)))
              ],
            ),
          ]
        ),
      ]),
    ),
    );
  }
}
