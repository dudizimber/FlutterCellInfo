import 'dart:async';
import 'dart:convert';

import 'package:cell_info/CellResponse.dart';
import 'package:cell_info/SIMInfoResponse.dart';
import 'package:cell_info/cell_info.dart';
import 'package:cell_info/models/common/cell_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CellsResponse _cellsResponse;
  List<SimInfoList> _list;
  List<Map<dynamic, dynamic>> all = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  String currentDBM = "";

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    CellsResponse cellsResponse;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      String platformVersion = await CellInfo.getCellInfo;
      final body = json.decode(platformVersion);

      cellsResponse = CellsResponse.fromJson(body);

      CellType currentCellInFirstChip = cellsResponse.primaryCellList[0];
      if (currentCellInFirstChip.type == "LT  E") {
        currentDBM =
            "LTE dbm = " + currentCellInFirstChip.lte.signalLTE.dbm.toString();
      } else if (currentCellInFirstChip.type == "NR") {
        currentDBM =
            "NR dbm = " + currentCellInFirstChip.nr.signalNR.dbm.toString();
      } else if (currentCellInFirstChip.type == "WCDMA") {
        currentDBM = "WCDMA dbm = " +
            currentCellInFirstChip.wcdma.signalWCDMA.dbm.toString();

        print('currentDBM = ' + currentDBM);
      }

      print(cellsResponse.primaryCellList[0].lte.toJson());

      String simInfo = await CellInfo.getSIMInfo;
      final simJson = json.decode(simInfo);
      setState(() {
        _list = SIMInfoResponse.fromJson(simJson).simInfoList;
      });
      print(
          "desply name ${SIMInfoResponse.fromJson(simJson).simInfoList[0].displayName}");

      for (var cell in cellsResponse.primaryCellList) {
        all.add({'cell': cell, 'sim': _list[0]});
      }
      setState(() {});
    } on PlatformException {
      _cellsResponse = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _cellsResponse = cellsResponse;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: _cellsResponse != null
            ? ListView(
                children: all
                    .map((e) => Card(
                          child: Column(
                            children: [
                              Text(
                                e['sim'].displayName,
                              ),
                              Text(
                                'cdma=${e['cell'].cdma?.signalCDMA?.dbm}',
                              ),
                              Text(
                                'lte=${e['cell'].lte?.signalLTE?.dbm}; cid=${e['cell'].lte?.cid}',
                              ),
                              Text(
                                'gsm=${e['cell'].gsm?.signalGSM?.dbm}',
                              ),
                              Text(
                                'nr=${e['cell'].nr?.signalNR?.dbm}',
                              ),
                              Text(
                                'tdscdma=${e['cell'].tdscdma?.signalTDSCDMA?.dbm}',
                              ),
                              Text(
                                'wcdma=${e['cell'].wcdma?.signalWCDMA?.dbm}',
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              )
            : null,
      ),
    );
  }
}
