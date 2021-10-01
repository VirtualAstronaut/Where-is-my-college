

import 'dart:ui';

import 'package:flutter/material.dart';

OutlineInputBorder whiteBorder() {
  return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(style: BorderStyle.none));
}


OutlineInputBorder focusedWhiteBorder() {
  return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide:
          BorderSide(color: Colors.white, width: 2, style: BorderStyle.solid));
}

OutlineInputBorder focusedBlackBorder() {
  return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide:
          BorderSide(color: Colors.blue, width: 2, style: BorderStyle.solid));
}

RaisedButton whiteButton(String buttonName, double topleft, double bottomleft,
    double topright, double bottomright, function()) {
  return RaisedButton(
    onPressed: () {
      function();
    },
    padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topleft),
            bottomLeft: Radius.circular(bottomleft),
            topRight: Radius.circular(topright),
            bottomRight: Radius.circular(bottomright))),
    color: Colors.white,
    textColor: Colors.black,
    child: Text(
      buttonName,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
    ),
  );
}

RaisedButton whiteButton2(String buttonName, double topleft, double bottomleft,
    double topright, double bottomright, function()) {
  return RaisedButton(
    onPressed: () {
      function();
    },
    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topleft),
            bottomLeft: Radius.circular(bottomleft),
            topRight: Radius.circular(topright),
            bottomRight: Radius.circular(bottomright))),
    color: Colors.white,
    textColor: Colors.black,
    child: Text(
      buttonName,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    ),
  );
}

RaisedButton gradientButton(String buttonName, double topleft, double bottomleft,
    double topright, double bottomright, function()) {
  return
    RaisedButton(
      onPressed: () {
        function();
      },
      color: Colors.transparent,

      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topleft),
              bottomLeft: Radius.circular(bottomleft),
              topRight: Radius.circular(topright),
              bottomRight: Radius.circular(bottomright))),
      textColor: Colors.white,
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topleft),
            bottomLeft: Radius.circular(bottomleft),
            topRight: Radius.circular(topright),
            bottomRight: Radius.circular(bottomright)),
            gradient: LinearGradient(
            colors: [
            const Color(0xFF3366FF),
          const Color(0xFF00CCFF),
          ],
          begin: const FractionalOffset(0.0, 0.0),
        end: const FractionalOffset(1.0, 1.0))),
        child: Text(
          buttonName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
}

RaisedButton blackButton(String buttonName, double topleft, double bottomleft,
    double topright, double bottomright, function()) {
  return RaisedButton(
    onPressed: () {
      function();
    },
    padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topleft),
            bottomLeft: Radius.circular(bottomleft),
            topRight: Radius.circular(topright),
            bottomRight: Radius.circular(bottomright))),
    color: Colors.black,
    textColor: Colors.white,
    child: Text(
      buttonName,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
  );
}
Widget whiteBorderText(String data,{double size}){
  return Container(child: Text(data,style: TextStyle(),),decoration: BoxDecoration(border: Border.all(width: 2,color: Colors.white)),);
}
TextFormField whiteTransparentField(
  IconData inputIcon,
  String fieldName,
  TextEditingController controller, {
    validator,
  bool isPassword = false,
      bool autoFocus = false
}) {
  return TextFormField(


    controller: controller,
    autofocus: autoFocus,
    obscureText: isPassword,
    validator: validator,
    cursorColor: Colors.white,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(color: Colors.white),
      labelText: fieldName,
        hintStyle: TextStyle(color: Colors.white),
        focusedBorder: focusedWhiteBorder(),
        fillColor: Colors.white12,
        filled: true,
        suffixIcon: Icon(
          inputIcon,
          color: Colors.white,
        ),
//          icon: Icon(
//            inputIcon,
//            color: Colors.white,
//          ),
        enabledBorder: whiteBorder(),
      ),
  );
}

Text whiteText(String info, {double size,TextStyle style}){
  return Text(info,style: style == null ? TextStyle(color: Colors.white, fontSize: size) : style,);
}
LinearGradient blueGradient(){
  return LinearGradient(
      colors: [
        const Color(0xFF3366FF),
        const Color(0xFF00CCFF),
      ],
      begin: const FractionalOffset(0.0, 0.0),
      end: const FractionalOffset(1.0, 1.0));
}
TextFormField blackTransparentField(
  IconData inputIcon,
  String fieldName,
  TextEditingController controller, {
    validator,
  bool isPassword = false,
}) {
  return TextFormField(

    controller: controller,
    obscureText: isPassword,
   validator: validator,
    cursorColor: Colors.blueAccent,
    style: TextStyle(color: Colors.black),
    decoration: InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.auto,
        hintStyle: TextStyle(color: Colors.black),
        focusedBorder: focusedBlackBorder(),
        fillColor: Colors.white12,
        filled: true,
        suffixIcon: Icon(
          inputIcon,
          color: Colors.black,
        ),
        labelText: fieldName,
        enabledBorder: whiteBorder(),
        ),
  );
}
