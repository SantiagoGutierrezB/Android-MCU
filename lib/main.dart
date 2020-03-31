import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;

const PUBLIC_MCU_KEY = "";
const PRIVATE_MCU_KEY = "";

void main() => runApp(new MarvelApp());

class MarvelApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blueGrey
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(title:
          Text("Marvel Comics!"),),
          body: InfinityDudes(),
      ),
    );
  }
}

String generateMd5(String input) {
  return crypto.md5.convert(utf8.encode(input)).toString();
}

class InfinityComic{
  final String title;
  final String cover;
  InfinityComic(this.title, this.cover);
}

class InfinityDetail extends StatelessWidget{
  final InfinityComic infinityComic;
  InfinityDetail(this.infinityComic);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text(infinityComic.title),
        ),
        body: Image.network(
          infinityComic.cover,
        )
    );
  }
}

class InfinityDudes extends StatefulWidget {
  @override
  ListInfinityDudesState createState() =>
      new ListInfinityDudesState();
}

class ListInfinityDudesState extends State<InfinityDudes> {
  var _page = 0;
  var _offset = 10;
  var pageController = new TextEditingController();

  Future<List<InfinityComic>> getDudes() async {
    var now = new DateTime.now();
    var md5D = generateMd5(now.toString()+ PRIVATE_MCU_KEY + PUBLIC_MCU_KEY);
    var url = "https://gateway.marvel.com:443/v1/public/characters?limit=" + _offset.toString() +
        "&offset=" + (_offset * _page).toString() + "=10&ts=" + now.toString()+  "&apikey=" + PUBLIC_MCU_KEY + "&hash=" + md5D;
    print(url);

    var data = await http.get(url);
    var jsonData = json.decode(data.body);
    List<InfinityComic> dudes = [];
    var dataMarvel = jsonData["data"];
    var marvelArray = dataMarvel["results"];
    for (var dude in marvelArray) {
      var thumb = dude["thumbnail"];
      var image = "${thumb["path"]}.jpg";
      InfinityComic infinityComic = InfinityComic(dude["name"], image);
      print("DUDE: " + infinityComic.title);
      dudes.add(infinityComic);
    }

    return dudes;
  }

  void _nextMcuPage() {
    setState(() {
      _page = _page + 1;
    });
    pageController.text = (_page + 1).toString();
  }

  void _previousMcuPage() {
    setState(() {
      if(_page > 0) {
        _page = _page - 1;
      }
    });
    pageController.text = (_page + 1).toString();
  }

  void _setMcuPage(int pageValue) {
    setState(() {
      _page = pageValue - 1;
    });
    pageController.text = pageValue.toString();
  }

  Widget buildButton(IconData icon, String buttonTitle) {
    final Color tintColor = Colors.blue;
    return new Column(
      children: <Widget>[
        new Icon(icon, color: tintColor),
        new Container(
          margin: const EdgeInsets.only(top: 5.0),
          child: new Text(
            buttonTitle,
            style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: tintColor),),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            new Expanded(
              child: FutureBuilder(
                future: getDudes(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(snapshot.data == null) {
                    return Container(
                      child: Center(
                        child: Text("Loading..."),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      //itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(snapshot.data[index].cover),
                          ),
                          title: Text(snapshot.data[index].title),
                          onTap: () {
                            Navigator.push(context,
                                new MaterialPageRoute(builder:
                                    (context) => InfinityDetail(snapshot.data[index])));
                          },
                        );
                      },
                      itemCount: snapshot.data.length,
                    );
                  }
                },
              ),
            ),
            Container(
              //padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  // To go to previous MCU page
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      tooltip: 'Back',
                      color: Colors.blue,
                      onPressed: () {
                        _previousMcuPage();
                      },
                    ),
                  ),
                  //buildButton(Icons.arrow_back, "Back"),
                  // To show MCU page number
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        controller: pageController,
                        onSubmitted: (value) {
                          _setMcuPage(int.parse(value));
                        },
                      ),
                    ),
                  ),
                  // To go to next MCU page
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      tooltip: 'Back',
                      color: Colors.blue,
                      onPressed: () {
                        _nextMcuPage();
                      },
                    ),
                  ),
                  //buildButton(Icons.arrow_forward, "Next"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}

/*
class HelloWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RowWidget(),
        RowWidget(),
      ],
    );
  }
}

class RowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          color: Colors.blueAccent,
          height: 300.0, width: 400.0,
          child: Center(
              child: Text(
                "Hello DUDES!",
                style: TextStyle(fontSize: 45.0, color: Colors.white),
              )
          ),
        )
    );
  }
}

void main() {
  return runApp (
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Text(
                "Hello Dude Fluterrr!"
            ),
          ),
          body: HelloWidget(),
        ),
      )
  );
}

 */