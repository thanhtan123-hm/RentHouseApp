import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConnectivityWidgetWrapper extends StatefulWidget {
  final Widget child;

  ConnectivityWidgetWrapper({required this.child});

  @override
  _ConnectivityWidgetWrapperState createState() => _ConnectivityWidgetWrapperState();
}

class _ConnectivityWidgetWrapperState extends State<ConnectivityWidgetWrapper> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      var isConnected = results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);
      setState(() {
        _isConnected = isConnected;
      });
    });
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    var result = await Connectivity().checkConnectivity();
    var isConnected = result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi);
    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return Center(
        child: AlertDialog(
          title: Text('Không có kết nối Internet'),
          content: Text('Vui lòng kiểm tra kết nối internet của bạn và thử lại.'),
          actions: [
            TextButton(
              onPressed: () {
                _checkConnection();
              },
              child: Text('Thử lại'),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop(); // Thoát ứng dụng
              },
              child: Text('Thoát'),
            ),
          ],
        ),
      );
    }
    return widget.child;
  }

}
