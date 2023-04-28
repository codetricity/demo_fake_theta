import 'package:flutter/material.dart';
import 'package:theta_client_flutter/theta_client_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Oppkey THETA Simulator'),
        ),
        body: const MiniApp(),
      ),
    ),
  );
}

class MiniApp extends StatefulWidget {
  const MiniApp({Key? key}) : super(key: key);

  @override
  State<MiniApp> createState() => _MiniAppState();
}

class _MiniAppState extends State<MiniApp> {
  final _thetaClient = ThetaClientFlutter();
  String _mobilePlatform = 'device unknown';
  String _cameraInfo = 'unable to get camera info';
  Widget displayWidget = const Text('');

  final endpoint = 'https://fake-theta-alpha.vercel.app';
  // final endpoint = 'https://fake-theta.vercel.app';

  @override
  void initState() {
    super.initState();
    _initializeTheta();
  }

  void _initializeTheta() async {
    try {
      await _thetaClient.initialize(endpoint);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    var thetaInfo = await _thetaClient.getThetaInfo();

                    setState(() {
                      _cameraInfo =
                          '${thetaInfo.model}, FW ${thetaInfo.firmwareVersion},'
                          'SN: ${thetaInfo.serialNumber}';
                      displayWidget = Text(_cameraInfo);
                    });
                  },
                  child: const Text('info'),
                ),
                TextButton(
                  onPressed: () async {
                    var mobilePlatform =
                        await _thetaClient.getPlatformVersion();
                    setState(() {
                      _mobilePlatform = mobilePlatform ?? 'device unknown';
                      displayWidget = Text(_mobilePlatform);
                    });
                  },
                  child: const Text('OS'),
                ),
                TextButton(
                  onPressed: () async {
                    // var imageList =
                    //     await _thetaClient.listFiles(FileTypeEnum.image, 2);
                    var url = Uri.parse('$endpoint/osc/commands/execute');

                    var bodyMap = {
                      'name': 'camera.listFiles',
                      'parameters': {
                        'fileType': 'image',
                        'startPosition': 0,
                        'entryCount': 1,
                        'maxThumbSize': 0,
                        '_detail': true,
                      }
                    };
                    var bodyJson = jsonEncode(bodyMap);
                    var response = await http.post(url,
                        headers: {'Content-Type': 'application/json'},
                        body: bodyJson);
                    var listOfFiles = jsonDecode(response.body);
                    var encoder = const JsonEncoder.withIndent('  ');
                    var prettyResponse = encoder.convert(listOfFiles);
                    setState(() {
                      displayWidget = SingleChildScrollView(
                        child: Text(prettyResponse),
                      );
                    });
                  },
                  child: const Text('files'),
                ),
                TextButton(
                  onPressed: () async {
                    // var imageList =
                    //     await _thetaClient.listFiles(FileTypeEnum.image, 2);
                    var url = Uri.parse('$endpoint/osc/commands/execute');

                    var bodyMap = {
                      'name': 'camera.listFiles',
                      'parameters': {
                        'fileType': 'image',
                        'startPosition': 0,
                        'entryCount': 1,
                        'maxThumbSize': 0,
                        '_detail': true,
                      }
                    };
                    var bodyJson = jsonEncode(bodyMap);
                    var response = await http.post(url,
                        headers: {'Content-Type': 'application/json'},
                        body: bodyJson);
                    var imageUrl = jsonDecode(response.body)['results']
                        ['entries'][0]['fileUrl'];

                    setState(() {
                      displayWidget = SingleChildScrollView(
                        // child: Text(imageUrl.toString()),
                        child: Image.network(imageUrl),
                      );
                    });
                  },
                  child: const Text('thumbs'),
                ),
              ],
            ),
          ),
          Expanded(flex: 4, child: displayWidget),
        ],
      ),
    );
  }
}
