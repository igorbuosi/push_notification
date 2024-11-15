import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);
  static const route = '/notification-screen';

  @override
  Widget build(BuildContext context) {
    // Recupera o argumento passado pela rota e faz um cast para RemoteMessage
    final RemoteMessage? message =
        ModalRoute.of(context)!.settings.arguments as RemoteMessage?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications Page'),
      ),
      body: Center(
        child: message != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${message.notification?.title ?? 'Sem título'}'),
                  Text('${message.notification?.body ?? 'Sem corpo'}'),
                  Text('${message.data}'),
                ],
              )
            : const Text('Nenhuma mensagem recebida'),
      ),
    );
  }
}
