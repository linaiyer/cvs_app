import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdditionalResources extends StatefulWidget {
  const AdditionalResources({Key? key}) : super(key: key);

  @override
  State<AdditionalResources> createState() => _AdditionalResourcesState();
}

final controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setBackgroundColor(const Color(0x00000000))
  ..setNavigationDelegate(
    NavigationDelegate(
      onProgress: (int progress) {
        // Update loading bar.
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) {},
      onWebResourceError: (WebResourceError error) {},
      onNavigationRequest: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ),
  )..loadRequest(Uri.parse('https://www.heartfulnessinstitute.org'));

class _AdditionalResourcesState extends State<AdditionalResources> {
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
                        'Additional Resources',
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
              child: WebViewWidget(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}
