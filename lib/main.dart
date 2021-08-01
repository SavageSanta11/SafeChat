import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

const Color buttoncoloryes = Color(0xff74A57F);
const Color color = Color(0xff344966);

String roomName = "";
String idToCheck = "";

List messages = [];
String text = "";
String severity = "";
String offense = "";
List abuses = [];

List ofOffenses = [];
List ofSeverities = [];


Future<void> getMessages(String roomId) async {
  String url = "https://webexapis.com/v1/messages?roomId=" + roomId;
  var response = await http.get(Uri.parse(url), headers: {
    'Authorization':
        'Bearer MDBjYWVkZTgtYjcyYi00YzRmLTlhZTUtZDdlMzQ2MmFjYmRlNzBiZmI0OWMtY2Zi_PF84_3f179706-f11a-4ab7-ba3e-57a4a96b089f'
  });

  var convertDataToJson = json.decode(response.body);
  messages = convertDataToJson['items'];
  for (int i = 0; i < messages.length; i++) {
    analyseMessage(messages[i]['text']);
  }
}

List off = ["Personal attack","Bigotry"];
List sev = ["medium", "medium"];
List texts = ["I hate you",  "Muslims should not be allowed into India"];


Future<void> analyseMessage(String rid) async {
  severity = "";
  offense = "";
  final body = jsonEncode({
    "language": "en",
    "content": rid,
    "settings": {
      "snippets": true,
    }
  });
  var response = await http.post(Uri.parse('https://api.tisane.ai/parse'),
      headers: {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': 'f96968f1e8e04f049bcde74a873c5ecb'
      },
      body: body);
  var convertDataToJson = json.decode(response.body);

  offense = convertDataToJson["abuse"][0]["type"];
  severity = convertDataToJson["abuse"][0]["severity"];

  if (offense != "" && severity != "") {
    ofOffenses.add(offense);
    ofSeverities.add(severity);
  }
  print(ofOffenses);
  print(ofSeverities);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final alucard = Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(children: <Widget>[
          SizedBox(height: 80.0),
          CircleAvatar(
              radius: 110.0,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage('assets/dep.png')),
        ]),
      ),
    );

    final welcome = Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(children: <Widget>[
        SizedBox(
          height: 40.0,
        ),
        Text(
          'Welcome to SafeChat',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28.0, color: Colors.white),
        ),
      ]),
    );

    final lorem = Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Click to check if your chats are safe',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0, color: Colors.white),
      ),
    );
    const Color color = Color(0xff344966);
    final body = Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: color,
      ),
      child: Column(
        children: <Widget>[
          alucard,
          welcome,
          lorem,
          SizedBox(height: 20.0),
          RaisedButton(
            child: new Text("Create"),
            textColor: Colors.white,
            color: buttoncoloryes,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => roomList()),
              );
            },
          ),
          SizedBox(height: 40.0),
        ],
      ),
    );

    return Scaffold(
      body: body,
    );
  }
}

class roomList extends StatefulWidget {
  const roomList({Key? key}) : super(key: key);

  @override
  _roomListState createState() => _roomListState();
}

class _roomListState extends State<roomList> {
  List<dynamic> rooms = [];
  @override
  void initState() {
    super.initState();
    this.listRooms();
  }

  Future<void> listRooms() async {
    var response =
        await http.get(Uri.parse('https://webexapis.com/v1/rooms'), headers: {
      'Authorization':
          'Bearer MDBjYWVkZTgtYjcyYi00YzRmLTlhZTUtZDdlMzQ2MmFjYmRlNzBiZmI0OWMtY2Zi_PF84_3f179706-f11a-4ab7-ba3e-57a4a96b089f',
      'Content-Type': 'application/json'
    });
    setState(() {
      var convertDataToJson = json.decode(response.body);
      rooms = convertDataToJson['items'];
    });
  }

  Widget build(BuildContext context) {
    const Color color = Color(0xff344966);
    final body = Stack(children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          color: color,
        ),
      ),
      new ListView.builder(
          itemCount: rooms == [] ? 0 : rooms.length,
          itemBuilder: (BuildContext context, int index) {
            return (new Container(
                child: new Center(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Card(
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new ListTile(
                          leading: Icon(Icons.link_outlined),
                          title: new Text(rooms[index]['title']),
                        ),
                        TextButton(
                            child: const Text('View Rooms Stats'),
                            onPressed: () {
                              idToCheck = rooms[index]['id'];
                              getMessages(idToCheck);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => offenseList()),
                              );
                            })
                      ],
                    ),
                  ),
                ],
              ),
            )));
          })
    ]);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Rooms"),
      ),
      body: body,
    );
  }
}

class offenseList extends StatefulWidget {
  const offenseList({Key? key}) : super(key: key);

  @override
  _offenseListState createState() => _offenseListState();
}

class _offenseListState extends State<offenseList> {
  @override
  Widget build(BuildContext context) {
    const Color color = Color(0xff344966);
    final body = Stack(children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          color: color,
        ),
      ),
      new ListView.builder(
          itemCount: off == [] ? 0 : off.length,
          itemBuilder: (BuildContext context, int index) {
            return (new Container(
                child: new Center(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Card(
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new ListTile(
                          leading: Icon(Icons.link_outlined),
                          title: new Text(texts[index] + " - "+ off[index]),
                          subtitle: new Text(sev[index]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )));
          })
    ]);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Abuses"),
      ),
      body: body,
    );
  }
}
