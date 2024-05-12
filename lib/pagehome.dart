import 'package:flutter/material.dart';
import 'package:hehe/Logininterface/Loginscreen.dart';


class PageHome extends StatelessWidget {
  const PageHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My App"),
        backgroundColor: Theme.of(context)
            .colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment
                .center,
            children: [
              _buildButton(context,label: "Login Screen", destination: LoginScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String label, required Widget destination}) {
    double w = MediaQuery.of(context).size.width*0.75;
    return Container(
      width: w,
      child: ElevatedButton(
          onPressed: (){
            Navigator.of(context).push(
                MaterialPageRoute(builder:(context) => destination,)
            );
          },
          child: Text(label)
      ),
    );
  }
}