import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sixam_mart/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:sixam_mart/features/wallet/widgets/fund_payment_dialog_widget.dart';

// ---------- MyInAppWebView widget is below ----------

class PaymentScreen extends StatefulWidget {
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String paymentMethod;
  final String guestId;
  final String contactNumber;
  final String? subscriptionUrl;
  final int? storeId;
  final bool createAccount;
  final int? createUserId;

  const PaymentScreen({
    super.key,
    required this.orderModel,
    required this.isCashOnDelivery,
    this.addFundUrl,
    required this.paymentMethod,
    required this.guestId,
    required this.contactNumber,
    this.storeId,
    this.subscriptionUrl,
    this.createAccount = false,
    this.createUserId,
  });

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late String selectedUrl;
  double? _maximumCodOrderAmount;

  bool _empty(String? s) => s == null || s.isEmpty;

  @override
  void initState() {
    super.initState();

    // Build selectedUrl safely
    if (_empty(widget.addFundUrl) && _empty(widget.subscriptionUrl)) {
      final customerId = widget.createAccount
          ? widget.createUserId
          : (widget.orderModel.userId == 0 ? widget.guestId : widget.orderModel.userId);
      selectedUrl =
      '${AppConstants.baseUrl}/payment-mobile?customer_id=$customerId&order_id=${widget.orderModel.id}&payment_method=${widget.paymentMethod}';

      // Max COD amount (same logic you had)
      final addr = AddressHelper.getUserAddressFromSharedPref();
      if (addr?.zoneData != null) {
        for (ZoneData zData in addr!.zoneData!) {
          for (Modules m in zData.modules!) {
            if (m.id == Get.find<SplashController>().module!.id) {
              _maximumCodOrderAmount = m.pivot?.maximumCodOrderAmount;
              break;
            }
          }
        }
      }
    } else if (!_empty(widget.subscriptionUrl)) {
      selectedUrl = widget.subscriptionUrl!;
    } else {
      selectedUrl = widget.addFundUrl!;
    }

    if (kDebugMode) {
      print('=== payment url => $selectedUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _exitApp().then((v) => v!);
      },
      child: SafeArea(
        child: Scaffold(
          appBar: CustomAppBar(title: 'payment'.tr, onBackPressed: () => _exitApp()),
          body: MyInAppWebView(
            initialUrl: selectedUrl,
            orderID: widget.orderModel.id.toString(),
            orderType: widget.orderModel.orderType,
            orderAmount: widget.orderModel.orderAmount,
            maxCodOrderAmount: _maximumCodOrderAmount,
            isCashOnDelivery: widget.isCashOnDelivery,
            addFundUrl: widget.addFundUrl,
            subscriptionUrl: widget.subscriptionUrl,
            contactNumber: widget.contactNumber,
            storeId: widget.storeId,
            createAccount: widget.createAccount,
            guestId: widget.guestId,
            onClose: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    final isOrderPayment = _empty(widget.addFundUrl) && _empty(widget.subscriptionUrl);
    if (isOrderPayment) {
      return Get.dialog(PaymentFailedDialog(
        orderID: widget.orderModel.id.toString(),
        orderAmount: widget.orderModel.orderAmount,
        maxCodOrderAmount: _maximumCodOrderAmount,
        orderType: widget.orderModel.orderType,
        isCashOnDelivery: widget.isCashOnDelivery,
        guestId: widget.createAccount ? widget.createUserId.toString() : widget.guestId,
      ));
    } else {
      return Get.dialog(FundPaymentDialogWidget(
        isSubscription: !_empty(widget.subscriptionUrl),
      ));
    }
  }
}


class MyInAppWebView extends StatefulWidget {
  final String initialUrl;

  final String orderID;
  final String? orderType;
  final double? orderAmount;
  final double? maxCodOrderAmount;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String? subscriptionUrl;
  final String? contactNumber;
  final int? storeId;
  final bool createAccount;
  final String guestId;
  final VoidCallback? onClose;

  const MyInAppWebView({
    super.key,
    required this.initialUrl,
    required this.orderID,
    required this.orderType,
    required this.orderAmount,
    required this.maxCodOrderAmount,
    required this.isCashOnDelivery,
    this.addFundUrl,
    this.subscriptionUrl,
    this.contactNumber,
    this.storeId,
    required this.createAccount,
    required this.guestId,
    this.onClose,
  });

  @override
  State<MyInAppWebView> createState() => _MyInAppWebViewState();
}

class _MyInAppWebViewState extends State<MyInAppWebView> {
  final bool _canRedirect = true;

  InAppWebViewController? _controller;
  PullToRefreshController? _pull;
  bool _createdNotified = false;
  bool _loading = true;

  WebUri _toWebUri(dynamic u) => (u is WebUri) ? u : WebUri(u?.toString() ?? '');

  // same-name helpers for compatibility with your old class
  Future onBrowserCreated() async {
    if (kDebugMode) print("\n\nBrowser Created!\n\n");
  }

  Future _onLoadStart(Object? url) async {
    if (kDebugMode) print("\n\nStarted: $url\n\n");
    if (url != null) {
      Get.find<OrderController>().paymentRedirect(
        url: url.toString(),
        canRedirect: _canRedirect,
        onClose: () => close(),
        addFundUrl: widget.addFundUrl,
        orderID: widget.orderID,
        contactNumber: widget.contactNumber,
        storeId: widget.storeId,
        subscriptionUrl: widget.subscriptionUrl,
        createAccount: widget.createAccount,
        guestId: widget.guestId,
      );
    }
  }

  Future _onLoadStop(Object? url) async {
    _pull?.endRefreshing();
    if (kDebugMode) print("\n\nStopped: $url\n\n");
    if (url != null) {
      Get.find<OrderController>().paymentRedirect(
        url: url.toString(),
        canRedirect: _canRedirect,
        onClose: () => close(),
        addFundUrl: widget.addFundUrl,
        orderID: widget.orderID,
        contactNumber: widget.contactNumber,
        storeId: widget.storeId,
        subscriptionUrl: widget.subscriptionUrl,
        createAccount: widget.createAccount,
        guestId: widget.guestId,
      );
    }
  }

  void _onLoadError(Object? url, int code, String message) {
    _pull?.endRefreshing();
    if (kDebugMode) print("Can't load [$url] Error: $message");
  }

  void _onProgressChanged(int progress) {
    if (progress == 100) _pull?.endRefreshing();
    if (kDebugMode) print("Progress: $progress");
  }

  void onExit() {
    if (kDebugMode) print("\n\nBrowser closed!\n\n");
  }

  Future<NavigationActionPolicy> _shouldOverride(NavigationAction nav) async {
    if (kDebugMode) print("\n\nOverride ${nav.request.url}\n\n");
    return NavigationActionPolicy.ALLOW;
  }

  void _onLoadResource(LoadedResource resource) {
    if (kDebugMode) {
      print("Started at: ${resource.startTime}ms ---> duration: ${resource.duration}ms ${resource.url ?? ''}");
    }
  }

  void _onConsoleMessage(ConsoleMessage cm) {
    if (kDebugMode) {
      print("""
    console output:
      message: ${cm.message}
      messageLevel: ${cm.messageLevel.toValue()}
   """);
    }
  }

  void close() => widget.onClose?.call();

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android) {
      InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
    }
    _pull = PullToRefreshController(onRefresh: () async {
      final url = await _controller?.getUrl();
      if (url != null) {
        await _controller?.loadUrl(urlRequest: URLRequest(url: url));
      } else {
        _pull?.endRefreshing();
      }
    });
  }

  @override
  void dispose() {
    onExit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
          initialSettings: InAppWebViewSettings(
            useShouldOverrideUrlLoading: true,
            useOnLoadResource: true,
            javaScriptEnabled: true,
          ),
          pullToRefreshController: _pull,

          onWebViewCreated: (c) async {
            _controller = c;
            if (!_createdNotified) {
              _createdNotified = true;
              await onBrowserCreated();
            }
          },

          onLoadStart: (c, url) async {
            setState(() => _loading = true);
            await _onLoadStart(url);
          },

          onLoadStop: (c, url) async {
            setState(() => _loading = false);
            await _onLoadStop(url);
          },

          onLoadError: (c, url, code, message) {
            setState(() => _loading = false);
            _onLoadError(url, code, message);
          },

          onProgressChanged: (c, progress) {
            _onProgressChanged(progress);
          },

          shouldOverrideUrlLoading: (c, nav) async => _shouldOverride(nav),

          onLoadResource: (c, res) => _onLoadResource(res),

          onConsoleMessage: (c, cm) => _onConsoleMessage(cm),
        ),

        if (_loading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
