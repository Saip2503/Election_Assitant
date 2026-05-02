import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

class ECIResultsWebView extends StatefulWidget {
  const ECIResultsWebView({super.key});

  @override
  State<ECIResultsWebView> createState() => _ECIResultsWebViewState();
}

class _ECIResultsWebViewState extends State<ECIResultsWebView> {
  final String _viewID = 'eci-results-iframe';

  @override
  void initState() {
    super.initState();
    // Register the iframe view factory
    ui_web.platformViewRegistry.registerViewFactory(
      _viewID,
      (int viewId) {
        final element = html.IFrameElement()
          ..src = 'https://results.eci.gov.in/'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'fullscreen';
        return element;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewID);
  }
}
