import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsOfUse extends StatefulWidget {

  const TermsOfUse({Key? key}) : super(key: key);

  @override
  _TermsOfUseState createState() => _TermsOfUseState();

}

class _TermsOfUseState extends State<TermsOfUse> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 40),
        child: Column(
          children: <Widget>[
            SizedBox(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(
                          'assets/icons/back_arrow.png',
                          height: 30,
                          width: 30,
                        ),
                      ),
                      const Expanded(child:  Text(
                          'Terms and Conditions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            // decoration: TextDecoration.underline,
                            color: Color(0xff744EC3),
                            fontSize: 30,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400),
                      ),),
                      const SizedBox(
                        width: 30,
                      )
                    ],
                  ),
                  SizedBox(height: 5),
                  Divider(
                    color: Color(0xff485370),
                  ),
                ],
              ),
            ),
            Expanded(
              child: WebView(
                initialUrl:
                    'https://www.heartfulnessinstitute.org/terms-of-use',
                javascriptMode: JavascriptMode.unrestricted,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
