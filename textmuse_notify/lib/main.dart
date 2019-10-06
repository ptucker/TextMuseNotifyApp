// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TextMuse Push Notification',
      home: Scaffold(
        appBar: AppBar(
          title: Text('TextMuse Push Notification'),
        ),
        body: Notification(),
      ),
    );
  }
}

class Notification extends StatefulWidget {
  @override NotificationState createState() => NotificationState();
}

class NotificationState extends State<Notification> {
  @override Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(child: Text('version')), 
              Expanded(child: DropdownButton<String>(
                items: <int>[1,2,3].map<DropdownMenuItem<String>>((int v) { 
                  return DropdownMenuItem<String>(value: v.toString(), child: Text(v.toString())); 
                }).toList(),
              )
              ),
            ],
            ),
            Row(children: <Widget>[
              Expanded(child: Text('highlight search')),
              Expanded(child: TextField()),
              Expanded(child: FlatButton(child: Text('search'), onPressed: () {},)),
            ],
            ),
            Row(children: <Widget>[
              Expanded(child: Text('notification')),
              Expanded(child: TextField()),
            ],
            ),
            Row(children: <Widget>[
              Expanded(child: Text('note to highlight')),
              Expanded(child: DropdownButton<String>(
                items: null
              ),
              ),
            ],
            ),
            Row(children: <Widget>[
              Expanded(child: Text('category to highlight')),
              Expanded(child: DropdownButton<String>(
                items: null
              ),
              ),
            ],
            ),
            Row(children: <Widget>[
              Expanded(child: FlatButton(child: Text('notify'), onPressed: () {},),),
            ],
            )
          ],
        ),
      ),
    );
  }
}