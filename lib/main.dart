import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:senty_flutter/model/Sento.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Senty',
        theme: new ThemeData(primaryColor: Colors.blue),
        home: new SentoList());
  }
}

class SentoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new SentoListState();
}

class SentoListState extends State<SentoList> {
  final Set<Sento> _savedSento = new Set<Sento>();
  final TextStyle _biggerFont = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Senty'),
          actions: <Widget>[
            new IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
          ],
        ),
        body: new StreamBuilder(
          stream: Firestore.instance.collection('sento').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text('Loading...');
            return new ListView.builder(
                itemCount: snapshot.data.documents.length,
                padding: EdgeInsets.all(16.0),
                itemExtent: 55.0,
                itemBuilder: (context, index) {
                  return _buildListItem(
                      context, snapshot.data.documents[index]);
                });
          },
        ));
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    final sento = new Sento(document.documentID, document['name']);
    final bool alreadySaved = _savedSento.contains(sento);
    return new ListTile(
      key: new ValueKey(document.documentID),
      title: new Text(document['name'], style: _biggerFont),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _savedSento.remove(sento);
          } else {
            _savedSento.add(sento);
          }
        });
      },
    );
  }

  void _pushSaved() {
    Navigator
        .of(context)
        .push(new MaterialPageRoute(builder: (BuildContext context) {
      final Iterable<ListTile> tiles = _savedSento.map((Sento sento) {
        return new ListTile(
          title: new Text(sento.name, style: _biggerFont),
          subtitle: new Text(sento.id),
        );
      });
      final List<Widget> divided =
          ListTile.divideTiles(context: context, tiles: tiles).toList();

      return new Scaffold(
          appBar: new AppBar(title: Text('お気に入りの銭湯')),
          body: new ListView(children: divided));
    }));
  }
}
