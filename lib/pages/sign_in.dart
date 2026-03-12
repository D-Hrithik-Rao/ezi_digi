import 'package:flutter/material.dart';

class SignIn extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  const SignIn({super.key,required this.hintText, required this.obscureText,required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          children: [
            //logo
            Icon(Icons.lock,size: 100,),
            const SizedBox(height: 50),
            //welcome back text
            Text("Welcome Back You have been missed",
              style: TextStyle(color: Colors.grey[700],fontSize: 16),
            ),
            const SizedBox(height: 25),
            //username textfield
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  hintText:hintText,
                ),
              ),
            ),
            //password textfield
            // sign in button
            //
          ],
        ),
      ),
      // appBar: AppBar(
      //   title: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 65),
      //     child: Text("Welcome to Ezi Digi",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,),
      //     ),
      //   ),
      //   backgroundColor: Colors.deepPurple,
      //   ),
      //   body: Center(
      //     child: Card(
      //       child: Column(
      //        children: [
      //         TextField(
                
      //         ),
      //         TextField(
      //           obscureText: true,
      //         ),
      //         ElevatedButton(onPressed: (){}, child: Text("Sign In"))
      //        ],
      //       ),
      //     ),
      //   ),
    );
  }
}