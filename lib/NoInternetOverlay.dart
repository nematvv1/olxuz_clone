
import 'package:flutter/material.dart';
import '../connectiwetiy.dart';

class NoInternetOverlay extends StatelessWidget {
  final Widget child;

  const NoInternetOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService().stream,
      builder: (context, snapshot) {
        final connected = snapshot.data ?? true;

        return Stack(
          children: [
            child,
            if (!connected)
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: Image.asset("assets/images/no_internet.png", width: 250),
              ),
          ],
        );
      },
    );
  }
}
