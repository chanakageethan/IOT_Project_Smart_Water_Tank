import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:math';

import 'package:mqtt_client/mqtt_server_client.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

late MqttServerClient client;

class _HomeState extends State<Home> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int waterLevel = 0;

  mqttConnect() async {
    client = new MqttServerClient("broker.emqx.io", "client-1");
    client.keepAlivePeriod = 60;
    client.autoReconnect = true;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print(e.toString());
    }
    //subscribe
    client.subscribe("Mysensor", MqttQos.atLeastOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      /// The above may seem a little convoluted for users only interested in the
      /// payload, some users however may be interested in the received publish message,
      /// lets not constrain ourselves yet until the package has been in the wild
      /// for a while.
      /// The payload is a byte buffer, this will be specific to the topic
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');

      setState(() {
        waterLevel = int.parse(pt);
      });
    });
  }

  void onConnected() {
    print('Connected');
  }

  void onDisconnected() {
    print('Disconected');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mqttConnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => Padding(
          padding: EdgeInsets.only(
            left: constraints.maxWidth / 5,
            right: constraints.maxWidth /5,
            top: constraints.maxHeight / 8,
            bottom: constraints.maxHeight * 0.02,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white70),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: _refreshController,
                child: FAProgressBar(
                    borderRadius: BorderRadius.circular(8),
                    direction: Axis.vertical,
                    verticalDirection: VerticalDirection.up,
                    currentValue: waterLevel,
                    displayText: '%',
                    size: 300,
                    backgroundColor: Colors.black38,
                    progressColor: (waterLevel < 10) ? Colors.red : Colors.blue),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
