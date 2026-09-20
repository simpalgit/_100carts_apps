import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:carts_app/Utils/appcolors.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const InAppWebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  InAppWebViewController? webViewController;
  double progress = 0;
  bool isLoading = true;
  bool hasError = false;
  String currentUrl = '';
  int loadingPercentage = 0;

  static const String _defaultUserAgent =
      "Mozilla/5.0 (Linux; Android 13; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.6261.119 Mobile Safari/537.36";

  @override
  void initState() {
    super.initState();
    currentUrl = widget.url;
  }

  String _cleanDomain(String urlStr) {
    try {
      final uri = Uri.parse(urlStr);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final domain = _cleanDomain(currentUrl.isNotEmpty ? currentUrl : widget.url);

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0.5,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: blackColor, size: 20),
          onPressed: () async {
            if (webViewController != null && await webViewController!.canGoBack()) {
              webViewController!.goBack();
            } else {
              Get.back();
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: blackColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (domain.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: Colors.green, size: 12),
                  const SizedBox(width: 3),
                  Text(
                    domain,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: blackColor),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                hasError = false;
                isLoading = true;
              });
              webViewController?.reload();
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded, color: primaryColor),
            tooltip: 'Open in Browser',
            onPressed: () async {
              final uri = Uri.parse(currentUrl.isNotEmpty ? currentUrl : widget.url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (isLoading)
              PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                  minHeight: 3,
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                    initialSettings: InAppWebViewSettings(
                      userAgent: _defaultUserAgent,
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      databaseEnabled: true,
                      useShouldOverrideUrlLoading: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                      thirdPartyCookiesEnabled: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                      mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                      useWideViewPort: true,
                      loadWithOverviewMode: true,
                      supportZoom: true,
                      builtInZoomControls: true,
                      displayZoomControls: false,
                      cacheEnabled: true,
                      transparentBackground: false,
                    ),
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    shouldOverrideUrlLoading: (controller, navigationAction) async {
                      var uri = navigationAction.request.url;
                      if (uri != null) {
                        if (!["http", "https", "file", "chrome", "data", "javascript", "about"]
                            .contains(uri.scheme)) {
                          if (await canLaunchUrl(uri)) {
                            // Launch the App outside for tel:, mailto: etc
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                            return NavigationActionPolicy.CANCEL;
                          }
                        }
                      }
                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        isLoading = true;
                        hasError = false;
                        currentUrl = url?.toString() ?? widget.url;
                      });
                    },
                    onLoadStop: (controller, url) {
                      setState(() {
                        isLoading = false;
                        currentUrl = url?.toString() ?? widget.url;
                      });
                    },
                    onProgressChanged: (controller, progressValue) {
                      setState(() {
                        progress = progressValue / 100;
                        loadingPercentage = progressValue;
                        if (progressValue == 100) {
                          isLoading = false;
                        }
                      });
                    },
                    onReceivedError: (controller, request, error) {
                      if (request.isForMainFrame == true) {
                        setState(() {
                          isLoading = false;
                          hasError = true;
                        });
                      }
                    },
                  ),
                  if (hasError)
                    Container(
                      color: whiteColor,
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.signal_cellular_connected_no_internet_4_bar_rounded,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load ${widget.title}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: blackColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please check your network connection and try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  hasError = false;
                                  isLoading = true;
                                });
                                webViewController?.reload();
                              },
                              icon: const Icon(Icons.refresh_rounded, color: whiteColor),
                              label: const Text(
                                'Retry',
                                style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
