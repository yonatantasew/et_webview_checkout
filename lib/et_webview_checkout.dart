library et_webview_checkout;

// lib/webview_service.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebCheckout {
  final WebViewController controller = WebViewController();
  final String? returnUrl;
  final String? refererUrl;
  final bool isPaymentUrl;
  Completer<void>? navigationCompleter;
  final BuildContext context;
  bool isLinkPaymentUrl = false;
  final Function(BuildContext)? onReturnUrlNavigation;

  WebCheckout({
   required this.context,
    required this.returnUrl,
    this.refererUrl,
    this.isPaymentUrl = true,
    String url = '',
    required this.onReturnUrlNavigation,
  }) {
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setNavigationDelegate(buildNavigationDelegate());
    // Set the desktop user agent
    controller.setUserAgent(
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
    );
    try {
      controller.loadRequest(
        Uri.parse(url),
        headers: {'Referer':refererUrl?? returnUrl??''},
      );
    } catch (e) {
      debugPrint('Failed to load URL: $e');
    }
    controller.addJavaScriptChannel(
      'HomeButtonChannel',
      onMessageReceived: (message) {
        navigationCompleter?.complete();
         navigateToHome();
      },
    );
    injectZoomOutScript();
    isLinkPaymentUrl = isPaymentUrl;
  }

  NavigationDelegate buildNavigationDelegate() {
    return NavigationDelegate(
      onPageFinished: (String url) async {
        debugPrint(url);
        if (isLinkPaymentUrl && isTeleBirrPaymentConfirmationUrl(url)) {
          // Reapply the zoom-out script after the page finishes loading
          injectZoomOutScript();
          isPaymentReceiptUrl(url) ? injectHomeButton() : {};
        }

        if (isLinkPaymentUrl && isPaymentReceiptUrl(url)) {
          injectHomeButton();
        }
      },
      onWebResourceError: (WebResourceError error) {},
      onNavigationRequest: (NavigationRequest request) {
        if (isLinkPaymentUrl && isReturnUrl(request.url)) {
          return NavigationDecision.prevent; // Prevent navigation
        }
        final validUrl =
            request.url.startsWith('http') || request.url.startsWith('https');
        final kcbConsumerUrl = request.url.startsWith('kcbconsumer://');
        if (validUrl) {
          return NavigationDecision.navigate;
        } else if (kcbConsumerUrl) {
          return NavigationDecision.prevent;
        } else {
          return NavigationDecision.navigate;
        }
      },
    );
  }
  // Navigate to the home view
  void navigateToHome() {
  onReturnUrlNavigation!(context); // Pass context to navigate
  }

  // check if the url contains the payment verification or receipt urls so that it cod be used to show receipts and navigate home
  bool isPaymentReceiptUrl(String url) {
    return url.contains("payment-receipt") || url.contains("pcSuccess");
  }

  // check if the url contains the payment verification or receipt urls so that it cod be used to show receipts and navigate home
  bool isTeleBirrPaymentConfirmationUrl(String url) {
    return url.contains("ethiotelebirr.et");
  }

  /// check if the url is the return url so that payment is verified and navigation is stopped
  bool isReturnUrl(String url) {
    return url.contains(returnUrl ?? ''); // Replace with your implementation
  }

  // inject javascript to show "Go Home" button on receipt page
  void injectHomeButton() async {
    final script = await rootBundle.loadString('assets/scripts/redirect_script.js');
    try {
      controller.runJavaScript(script);
    } catch (e) {
      debugPrint('Error injecting JavaScript: $e');
    }
  }

  void injectZoomOutScript() async {
    final zoomOutScript = await rootBundle.loadString('assets/scripts/zoom_out_viewPort.js');
    try {
      controller.runJavaScript(zoomOutScript);
    } catch (e) {
      debugPrint('Error injecting JavaScript: $e');
    }
  }
}