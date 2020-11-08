import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webrtc_flutter_test/webrtc_viewmodel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final viewModel = WebRtcViewModel();
  final controller = TextEditingController();
  final msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<RTCSessionDescription> getSdpFromUser(BuildContext context) async {
    controller.clear();
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 10,
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Done"),
            )
          ],
        ),
      ),
    );
    RTCSessionDescription offer;
    try {
      final offerMap = json.decode(controller.text);
      offer = RTCSessionDescription(
        offerMap["sdp"],
        offerMap["type"],
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "make sure the format is correct");
    }
    return offer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: RaisedButton(
                    child: Text("OFFER"),
                    onPressed: () {
                      viewModel.offerConnection();
                    },
                  ),
                ),
                Expanded(
                  child: RaisedButton(
                    child: Text("ANSWER"),
                    onPressed: () async {
                      final offer = await getSdpFromUser(context);
                      if (offer == null) return;
                      viewModel.answerConnection(offer);
                    },
                  ),
                ),
                Expanded(
                  child: RaisedButton(
                      child: Text("SET REMOTE"),
                      onPressed: () async {
                        final answer = await getSdpFromUser(context);
                        if (answer == null) return;
                        viewModel.acceptAnswer(answer);
                      }),
                ),
              ],
            ),
            Expanded(
              child: Observer(builder: (_) {
                return ListView.builder(
                  itemCount: viewModel.messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final message = viewModel.messages.reversedIndex(index);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            message.sender,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(message.message),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      await viewModel.sendMessage(msgController.text);
                      msgController.clear();
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}

extension<T> on List<T> {
  T reversedIndex(int index) {
    return this[length - index - 1];
  }
}
