import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String? qrInfo;

  const VerifyCodeScreen({Key? key, required this.qrInfo}) : super(key: key);

  @override
  _VerifyCodeScreenState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isValidCode = false;

  @override
  void initState() {
    super.initState();
    validateCode();
  }

  void validateCode() {
    List<String> qrInfoSeparated = getQRInfoSeparated(widget.qrInfo);
    String eventNameFromQR = qrInfoSeparated[0];

    // Step 1: Check if the eventName field matches the eventNameFromQR
    firestore.collection('events').get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        String eventName = doc['eventName'];

        if (eventName == eventNameFromQR) {
          // Step 2: Check if the code has been uploaded
          List<String> usersQrCodes =
              List<String>.from(doc['usersQrCodes'] ?? []);
          String paymentSessionID = qrInfoSeparated[1];

          if (!usersQrCodes.contains(paymentSessionID)) {
            // Code is valid
            setState(() {
              isValidCode = true;
            });

            // Upload the code
            usersQrCodes.add(paymentSessionID);
            doc.reference.update({'usersQrCodes': usersQrCodes});

            return; // Stop further iteration
          }
        }
      }

      // Code is invalid
      setState(() {
        isValidCode = false;
      });
    });
  }

  List<String> getQRInfoSeparated(String? qrinfo) {
    int delimiterIndex = qrinfo!.indexOf('_');
    String eventName = qrinfo.substring(0, delimiterIndex);
    String paymentSessionID = qrinfo.substring(delimiterIndex + 1);

    return [eventName, paymentSessionID];
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = isValidCode ? Colors.green : Colors.red;
    String message = isValidCode ? 'Codigo Valido' : 'Codigo Invalido';

    return Scaffold(
      backgroundColor:  backgroundColor,
      body: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 48),
        ),
      ),
    );
  }
}
