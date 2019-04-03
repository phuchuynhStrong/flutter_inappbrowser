import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class InlineExampleScreen extends StatefulWidget {
  @override
  _InlineExampleScreenState createState() => new _InlineExampleScreenState();
}

class _InlineExampleScreenState extends State<InlineExampleScreen> {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  var isInitialized = false;
  var data = "";


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[
      Container(
        padding: EdgeInsets.all(20.0),
        child: Text(
            "CURRENT URL\n${(url.length > 50) ? url.substring(0, 50) + "..." : url}"),
      ),
      Container( 
        padding: EdgeInsets.all(10.0),
        child: progress < 1.0 ? LinearProgressIndicator(value: progress) : null
      ),
      Expanded(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          child: GestureDetector(
            child: InAppWebView(
              initialUrl: "https://note.hasbrain.com/notebook/5c6a1c34400c95001177ea88",
              initialHeaders: {},
              initialOptions: {
                "databaseEnabled": true,
                "domStorageEnabled": true,
              },
              onWebViewCreated: (InAppWebViewController controller) {
                webView = controller;
              },
              onLoadStop: (controller, url) {
                if (!isInitialized) {
                  var script =
                      "window.localStorage.setItem('bookmark_refresh_token','eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwcm9qZWN0X2lkIjoiNWFkODU4MjRiM2NlYzM0MTUzMDRhZWI2IiwiYWNjb3VudF9pZCI6IjViY2Q3YTU1YzI3NWM3MTRhYzJmNGM4NyIsInJvbGUiOiJjb250cmlidXRvciIsInByb2ZpbGVfaWQiOiI1YmNkN2E1NTU1ZjljODM0NjE0N2ZiMjIiLCJkaXN0aW5jdF9pZCI6IjViY2Q3YTU1NTVmOWM4MzQ2MTQ3ZmIyMiIsImlhdCI6MTU1Mzg1MzkwMCwiZXhwIjoxNTU2NDQ1OTAwfQ.nmhWch_UHW1FAhKlUXMmLA-PvtmLNK9krhZT45alo20');" +
                          "window.localStorage.setItem('bookmark_token','eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwcm9qZWN0X2lkIjoiNWFkODU4MjRiM2NlYzM0MTUzMDRhZWI2IiwiYWNjb3VudF9pZCI6IjViY2Q3YTU1YzI3NWM3MTRhYzJmNGM4NyIsInJvbGUiOiJjb250cmlidXRvciIsInByb2ZpbGVfaWQiOiI1YmNkN2E1NTU1ZjljODM0NjE0N2ZiMjIiLCJkaXN0aW5jdF9pZCI6IjViY2Q3YTU1NTVmOWM4MzQ2MTQ3ZmIyMiIsImlhdCI6MTU1Mzg1MzkwMCwiZXhwIjoxNTU1MDYzNTAwfQ.TdbGDiZwVtrh-Ydr_SKPjoPzBem7YQof-bImao_BsRI');";

                  webView.injectScriptCode(script);
                  setState(() {
                    isInitialized = true;
                    webView.reload();
                  });
                }
                else {
                  webView.injectScriptCode("""
                        var intelRemoveMiniMenu = setInterval(() => {
                  if (document.getElementsByClassName('undefined hover-menu css-yx0xkg') && document.getElementsByClassName('undefined hover-menu css-yx0xkg')[0]) {
                    document.getElementsByClassName('undefined hover-menu css-yx0xkg')[0].remove();
                    clearInterval(intelRemoveMiniMenu);
                  }
                }, 100);
                var intelRemoveSideBar = setInterval(() => {
                  if (document.getElementById('notebook-sidebar')) {
                    document.getElementById('notebook-sidebar').remove();
                    clearInterval(intel);
                  }
                }, 100);
                var intelAddPadding = setInterval(() => {
                  if (document.getElementById('notebook-detail-wrapper')) {
                    document.getElementById('notebook-detail-wrapper').style.padding = "0px 24px";
                    clearInterval(intelAddPadding);
                  }
                }, 100);
                var intelRemoveStatusBar = setInterval(() => {
                  if (document.getElementsByClassName('status-bar') && document.getElementsByClassName('status-bar')[0]) {
                    document.getElementsByClassName('status-bar')[0].remove();
                    clearInterval(intelRemoveStatusBar);
                  }
                }, 100);
                var intelRemoveBreadcrumb = setInterval(() => {
                  if (document.getElementsByClassName('breadcrumb-wrapper') && document.getElementsByClassName('breadcrumb-wrapper')[0]) {
                    document.getElementsByClassName('breadcrumb-wrapper')[0].remove();
                    clearInterval(intelRemoveBreadcrumb);
                  }
                }, 100);
                var intelRemoveHandler = setInterval(() => {
                  if (document.getElementsByClassName('handler') && document.getElementsByClassName('handler')[0]) {
                    var handlers = document.getElementsByClassName('handler');
                    while(handlers[0]) {
                      handlers[0].parentNode.removeChild(handlers[0]);
                    }
                    clearInterval(intelRemoveHandler);
                  }
                }, 100);
                var intelBlockContent = setInterval(() => {
                  if (document.getElementsByClassName('block-content') && document.getElementsByClassName('block-content').length > 0) {
                    Array.prototype.slice.call(document.getElementsByClassName("block-content")).map((x) => x.setAttribute("contenteditable", "false"))
                    clearInterval(intelRemoveHandler);
                  }
                }, 100);
                     """);
                }
              },
              onLoadStart: (InAppWebViewController controller, String url) {
                print("started $url");
                setState(() {
                  this.url = url;
                });
              },
              onProgressChanged:
                  (InAppWebViewController controller, int progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
            ),
            onTap: () {
              print("onTap");
            },
            onDoubleTap: () {
              print("onDoubleTap");
            },
            onTapDown: (_) {
              print("onTapDown");
            },
          ),
        ),
      ),
      ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: Icon(Icons.arrow_back),
            onPressed: () {
              if (webView != null) {
                webView.goBack();
              }
            },
          ),
          RaisedButton(
            child: Icon(Icons.arrow_forward),
            onPressed: () {
              if (webView != null) {
                webView.goForward();
              }
            },
          ),
          RaisedButton(
            child: Icon(Icons.refresh),
            onPressed: () {
              webView.reload();
            },
          ),
        ],
      ),
    ]));
  }
}
