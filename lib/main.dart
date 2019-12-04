import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:async';

import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = new TextEditingController();

  Future<List<FileSystemEntity>> _getFilesFromDir() async {
    var path = await _localPath;
    return Directory("$path/").listSync();
  }

  final Random _random = Random.secure();

  String _createCryptoRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Images'),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _controller,
              ),
              RaisedButton(
                child: Text('Download'),
                onPressed: () async {
                  HttpClient client = new HttpClient();
                  var _downloadData = List<int>();
                  final path = await _localPath;
                  var fileSave =
                      new File('$path/${_createCryptoRandomString()}.jpg');
                  client
                      .getUrl(Uri.parse(_controller.value.text))
                      .then((HttpClientRequest request) {
                    return request.close();
                  }).then((HttpClientResponse response) {
                    response.listen((d) {
                      return _downloadData.addAll(d);
                    }, onDone: () {
                      fileSave.writeAsBytes(_downloadData);
                    });
                  });
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: FutureBuilder(
                  future: _getFilesFromDir(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    var count = snapshot.data.length;
                    return ListView.builder(
                      itemCount: count,
                      itemBuilder: (context, index) {
                        File file = new File(snapshot.data[index].path);
                        return Container(
                          child: Image.file(file, fit: BoxFit.cover),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

Future<String> get _localPath async {
  final List<Directory> directory =
      await getExternalStorageDirectories(type: StorageDirectory.pictures);
  return directory.first.path;
}
