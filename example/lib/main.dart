import 'dart:async';

import 'package:flutter/material.dart';
import 'package:linkify_plus/linkify/linkify.dart';
import 'package:linkify_plus/linkify_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const LinkifyExample());

class LinkifyExample extends StatelessWidget {
  const LinkifyExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'linkify_plus example',
      home: Scaffold(
        appBar: AppBar(title: const Text('linkify_plus example')),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Center(
                child: Linkify(
                  onOpen: _onOpen,
                  textScaleFactor: 2,
                  options: const LinkifyOptions(linkAsList: true),
                  text:
                      "Hi Jane,Please be advised your team has added a new educational resource \n#https://preprod.caremonitor.com.au/links/?c=UI0b5V0#Falls prevention – eyesight# to your resource library. ",
                ),
              ),
              Center(
                child: Linkify(
                  onOpen: _onOpen,
                  textScaleFactor: 2,
                  options: const LinkifyOptions(linkAsList: true),
                  text: "Made by #https://cretezy.com#falls#",
                ),
              ),
              Center(
                child: Linkify(
                  onOpen: _onOpen,
                  textScaleFactor: 2,
                  options: const LinkifyOptions(linkAsList: true),
                  text: "[Test](http://urltolinkto.com)",
                ),
              ),
              Center(
                child: Linkify(
                  onOpen: _onOpen,
                  textScaleFactor: 2,
                  options: const LinkifyOptions(linkAsList: true),
                  text: "[Mail](tel:123-456-7890)",
                ),
              ),
              Center(
                child: Linkify(
                  onOpen: _onOpen,
                  textScaleFactor: 2,
                  options: const LinkifyOptions(linkAsList: true),
                  text:
                      "Made by #https://dev.ihealthlabs.com/account/sign-up-success#iHealth# and unMade by #https://dev.google.com/account/sign-up-success#iHealth3# and unMade by https://dev.google.com/account/sign-up-success",
                ),
              ),
              Center(
                child: Linkify(
                    onOpen: _onOpen,
                    textScaleFactor: 2,
                    options: const LinkifyOptions(linkAsList: true),
                    text:
                        "Please find a link to an educational resource below.\n#https://stg.caremonitor.com.au/links/?c=V5cP5P5#Controlling fluid intake in heart failure#,\n#https://stg.caremonitor.com.au/links/?c=V5cP5N0#9 food and heart health myths#,\n#https://stg.caremonitor.com.au/links/?c=V5cP5Ok#Common investigations in cardiovascular disease#,\n#https://stg.caremonitor.com.au/links/?c=V5cP5NO#Anticoagulants & blood thinners#,\n#https://stg.caremonitor.com.au/links/?c=V5cP5Nj#Antiplatelet treatment#,\n#https://stg.caremonitor.com.au/links/?c=V5cP5O4#Cardiac rehabilitation videos#,\n#https://stg.caremonitor.com.au/links/?c=V5cP5OP#Client Services Charter#\n\nKind Regards,\nYour virtual care team \n"),
              ),

              Center(
                  child: Linkify(
                      onOpen: _onOpen,
                      textScaleFactor: 2,
                      options: const LinkifyOptions(linkAsList: true),
                      text:
                          "Hi starc,\n\nPlease be advised your team has added a new educational resource #https://preprod.caremonitor.com.au/links/?c=V5p44W4#Heart Attack Action Plan #\n#https://preprod.caremonitor.com.au/links/?c=V5p44X9#What is Diabetes?#\n#https://preprod.caremonitor.com.au/links/?c=V5p44WI#10 ways to manage your diabetes#\n#https://preprod.caremonitor.com.au/links/?c=V5p44XK#What is hypoglycaemia?#\n#https://preprod.caremonitor.com.au/links/?c=V5p44XV#Your eyes & diabetes#\n#https://preprod.caremonitor.com.au/links/?c=V5p44Xg#Your feet & diabetes#\n#https://preprod.caremonitor.com.au/links/?c=V5p44WS#Living well with diabetes [video]#\n#https://preprod.caremonitor.com.au/links/?c=V5p44Wd#Concerns about starting insulin#\n#https://preprod.caremonitor.com.au/links/?c=V5p44Wn#Adjusting to life with diabetes#\n#https://preprod.caremonitor.com.au/links/?c=V5p44Wx#Alcohol and diabetes# to your resource library. \n\nKind Regards,\nRamsay Home Health")),

              //
              Center(
                child: SelectableLinkify(
                  onOpen: _onOpen,
                  linkifiers: const [UserTagLinkifier()],
                  textScaleFactor: 4,
                  text: 'Hello @JohnDoe, did you see what @JaneDoe posted?',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onOpen(LinkableElement link) async {
    await launch(link.url);
  }
}
