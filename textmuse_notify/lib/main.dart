// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

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

class SkinInfo {
  String name, id;

  SkinInfo({this.id, this.name});
}

class Category {
  String name, id;

  Category({this.id, this.name});
}

class HighlightNote {
  String note, id;

  HighlightNote({this.id, this.note});
}

class Notification extends StatefulWidget {
  @override NotificationState createState() => NotificationState();
}

class NotificationState extends State<Notification> {
  List<dynamic> _versions;
  String _selectedVersion;
  List<dynamic> _categories;
  String _selectedCategory;
  List<dynamic>_highlightNotes;
  String _selectedHighlight;
  TextEditingController tcHighlight = TextEditingController();
  TextEditingController tcNotification = TextEditingController();

  @override void initState() {
    super.initState();

    final respVersions = http.get('https://www.textmuse.com/admin/getskins.php');
    respVersions.then((resp) {
      if (resp.statusCode == 200) {
        dynamic r = xml.parse(resp.body);
        dynamic v = r.findAllElements('s');
        _versions = v.map((s) {
          dynamic aid = s.attributes.where((a) {
            return a.name.local == 'id';
          });
          return SkinInfo(id: aid.first.value, name: s.text.trim());
        }).toList();
        _versions.insert(0, SkinInfo(id: '0', name: 'all'));
        _selectedVersion = _versions[0].id;
        setState(() {});
      }

    });

    fetchCategories();
  }

  void fetchCategories() {
    String url = 'https://www.textmuse.com/admin/categories.php';
    if (_selectedVersion != null && _selectedVersion.length > 0 && _selectedVersion != '0')
      url = url + '?sponsor=' + _selectedVersion;
    final respCategories = http.get(url);
    respCategories.then((resp) {
      if (resp.statusCode == 200) {
        dynamic r = xml.parse(resp.body);
        dynamic v = r.findAllElements('c');
        _categories = v.map((c) {
          dynamic aid = c.attributes.where((a) {
            return a.name.local == 'id';
          });
          return Category(id: aid.first.value, name: c.text.trim());
        }).toList();
        _categories.insert(0, Category(id: '0', name: '<none>'));
        _selectedCategory = _categories[0].id;
        setState(() {});
      }

    });
  }

  void findMatchNotes() {
    final url = "https://www.textmuse.com/admin/matchnotes.php?kws=" + tcHighlight.text;
    final respNotes = http.get(url);
    respNotes.then((resp) {
      if (resp.statusCode == 200) {
        dynamic r = xml.parse(resp.body);
        dynamic v = r.findAllElements('Note');
        _highlightNotes = v.map((c) {
          dynamic aid = c.attributes.where((a) {
            return a.name.local == 'ID';
          });
          return HighlightNote(id: aid.first.value, note: c.text.trim());
        }).toList();
        _highlightNotes.insert(0, HighlightNote(id: '0', note: '<none>'));
        _selectedHighlight = _highlightNotes[0].id;
        setState(() {});
      }

    });
  }

  @override Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(child: Text('version')), 
              Expanded(child: DropdownButton<String>(
                items: _versions == null ? null : 
                  _versions.map<DropdownMenuItem<String>>((dynamic s) => DropdownMenuItem<String>(value: s.id, child: Text(s.name)) ).toList(),
                value: _selectedVersion,
                onChanged: (v) { setState(() { _selectedVersion = v; fetchCategories(); } ); },
              )
              ),
            ],
            ),
            Row(children: <Widget>[
              Expanded(child: Text('highlight search')),
              Expanded(child: TextField(controller: tcHighlight,)),
              Expanded(child: FlatButton(
                child: Text('search'), 
                color: Theme.of(context).accentColor, 
                textColor: Colors.white, 
                onPressed: () { findMatchNotes(); },)
              ),
            ],
            ),
            Row(children: <Widget>[
              Expanded(child: Text('notification')),
              Expanded(child: TextField(controller: tcNotification, keyboardType: TextInputType.multiline, maxLines: null,)),
            ],
            ),
            Row(children: <Widget>[
              Expanded(child: Text('note to highlight')),
              Expanded(child: DropdownButton<String>(
                items: _highlightNotes == null ? null : 
                  _highlightNotes.map<DropdownMenuItem<String>>((dynamic s) => DropdownMenuItem<String>(value: s.id, child: Text(s.note)) ).toList(),
                value: _selectedHighlight,
                onChanged: (v) { setState(() { _selectedHighlight = v; } ); },
              ),
              ),
            ],
            ),
            Row(children: <Widget>[
              Expanded(child: Text('category to highlight')),
              Expanded(child: DropdownButton<String>(
                items: _categories == null ? null : 
                  _categories.map<DropdownMenuItem<String>>((dynamic s) => DropdownMenuItem<String>(value: s.id, child: ClipRect(child: Text(s.name))) ).toList(),
                value: _selectedCategory,
                onChanged: (v) { setState(() { _selectedCategory = v; } ); },
              ),
              ),
            ],
            ),
            Row(children: <Widget>[
              Expanded(child: FlatButton(
                child: Text('notify'),
                color: Theme.of(context).accentColor, 
                textColor: Colors.white, 
                onPressed: () {},),
              ),
            ],
            )
          ],
        ),
      ),
    );
  }
}