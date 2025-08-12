import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/payment/widgets/offline_payment_button.dart';

class PaymentMethodBottomSheet extends StatefulWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final int? storeId;
  final double totalPrice;
  const PaymentMethodBottomSheet({super.key, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive,
    required this.isWalletActive, required this.storeId, required this.totalPrice, required this.isOfflinePaymentActive});

  @override
  State<PaymentMethodBottomSheet> createState() => _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  bool canSelectWallet = true;
  bool notHideCod = true;
  bool notHideWallet = true;
  bool notHideDigital = true;
  final JustTheController tooltipController = JustTheController();
  final TextEditingController _amountController = TextEditingController();
  bool showChangeAmount = false;

  @override
  void initState() {
    super.initState();

    configurePartialPayment();
  }

  void configurePartialPayment() {
    if(!AuthHelper.isGuestLoggedIn()) {
      double walletBalance = Get.find<ProfileController>().userInfoModel!.walletBalance!;
      if(walletBalance < widget.totalPrice){
        canSelectWallet = false;
      }
      if(Get.find<CheckoutController>().isPartialPay){
        notHideWallet = false;
        if(Get.find<SplashController>().configModel!.partialPaymentMethod! == 'cod'){
          notHideCod = true;
          notHideDigital = false;
        } else if(Get.find<SplashController>().configModel!.partialPaymentMethod! == 'digital_payment'){
          notHideCod = false;
          notHideDigital = true;
        } else if(Get.find<SplashController>().configModel!.partialPaymentMethod! == 'both'){
          notHideCod = true;
          notHideDigital = true;
        }
      } else {
        notHideWallet = false;
        notHideCod = true;
        notHideDigital = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //bool isLoggedIn = AuthHelper.isLoggedIn();
    //bool isDesktop = ResponsiveHelper.isDesktop(context);

    return SizedBox(
      width: 550,
      child: GetBuilder<CheckoutController>(builder: (checkoutController) {
        bool disablePayments = checkoutController.paymentMethodIndex == 1 && !checkoutController.isPartialPay;

        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(Dimensions.radiusLarge),
              bottom: Radius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusLarge : 0),
            ),
          ),
          // padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            ResponsiveHelper.isDesktop(context) ? Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Get.back(),
                child: Container(
                  height: 30, width: 30,
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(50)),
                  child: const Icon(Icons.clear),
                ),
              ),
            ) : Align(
              alignment: Alignment.center,
              child: Container(
                height: 4, width: 35,
                margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text('choose_payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            // const SizedBox(height: Dimensions.paddingSizeSmall),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, top: 13),
                      child: Text('total_bill'.tr, style: robotoMedium.copyWith(fontSize: 14, color: Colors.grey.shade700)),
                    ),

                    Text(PriceConverter.convertPrice(widget.totalPrice), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor)),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    walletView(checkoutController),

                    widget.isCashOnDeliveryActive && notHideCod ? paymentButtonView(
                      title: 'cash_on_delivery'.tr,
                      isSelected: checkoutController.paymentMethodIndex == 0,
                      disablePayments: disablePayments,
                      onTap: disablePayments ? null : (){
                        checkoutController.setPaymentMethod(0);
                      },
                    ) : const SizedBox(),

                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    // changeAmountView(checkoutController),


                    widget.isDigitalPaymentActive && notHideDigital ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        border: Border.all(color: Theme.of(context).disabledColor, width: 0.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: Text('pay_via_online'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: disablePayments ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge!.color)),
                          ),

                          ListView.builder(
                              itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index){
                                bool isSelected = checkoutController.paymentMethodIndex == 2 && Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == checkoutController.digitalPaymentName;

                                return paymentButtonView(
                                  disablePayments: disablePayments,
                                  onTap: disablePayments ? null : () {
                                    checkoutController.setPaymentMethod(2);
                                    checkoutController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                                  },
                                  title: Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayTitle!,
                                  isSelected: isSelected,
                                  image: Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImageFullUrl,
                                );
                              }),
                        ],
                      ),
                    ) : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    widget.isOfflinePaymentActive ? OfflinePaymentButton(
                      isSelected: checkoutController.paymentMethodIndex == 3,
                      offlineMethodList: checkoutController.offlineMethodList,
                      isOfflinePaymentActive: widget.isOfflinePaymentActive,
                      onTap: disablePayments ? null : () => checkoutController.setPaymentMethod(3),
                      checkoutController: checkoutController, tooltipController: tooltipController,
                      disablePayment: disablePayments,
                    ) : const SizedBox(),

                    // Row(children: [
                    //   widget.isCashOnDeliveryActive && notHideCod ? Expanded(
                    //     child: Padding(
                    //       padding: EdgeInsets.only(right: widget.storeId == null && widget.isWalletActive && notHideWallet && isLoggedIn ? Dimensions.paddingSizeSmall : 0),
                    //       child: PaymentButtonNew(
                    //         icon: Images.codIcon,
                    //         title: 'cash_on_delivery'.tr,
                    //         isSelected: checkoutController.paymentMethodIndex == 0,
                    //         onTap: () {
                    //           checkoutController.setPaymentMethod(0);
                    //         },
                    //       ),
                    //     ),
                    //   ) : const SizedBox(),
                    //   // SizedBox(width: widget.storeId == null && widget.isWalletActive && notHideWallet && isLoggedIn ? 0 : Dimensions.paddingSizeLarge),
                    //
                    //   widget.storeId == null && widget.isWalletActive && notHideWallet && isLoggedIn ? Expanded(
                    //     child: Padding(
                    //       padding: EdgeInsets.only(left: widget.isCashOnDeliveryActive && notHideCod ? Dimensions.paddingSizeSmall : 0),
                    //       child: PaymentButtonNew(
                    //         icon: Images.partialWallet,
                    //         title: 'pay_via_wallet'.tr,
                    //         isSelected: checkoutController.paymentMethodIndex == 1,
                    //         onTap: () {
                    //           if(canSelectWallet) {
                    //             checkoutController.setPaymentMethod(1);
                    //           } else if(checkoutController.isPartialPay){
                    //             showCustomSnackBar('you_can_not_user_wallet_in_partial_payment'.tr);
                    //             Get.back();
                    //           } else{
                    //             showCustomSnackBar('your_wallet_have_not_sufficient_balance'.tr);
                    //             Get.back();
                    //           }
                    //         },
                    //       ),
                    //     ),
                    //   ) : const SizedBox(),
                    //
                    // ]),
                    // const SizedBox(height: Dimensions.paddingSizeLarge),
                    //
                    // widget.storeId == null && widget.isDigitalPaymentActive && notHideDigital ? Row(children: [
                    //   Text('pay_via_online'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                    //   Text(
                    //     'faster_and_secure_way_to_pay_bill'.tr,
                    //     style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                    //   ),
                    // ]) : const SizedBox(),
                    // SizedBox(height: widget.storeId == null && widget.isDigitalPaymentActive && notHideDigital ? Dimensions.paddingSizeLarge : 0),
                    //
                    // widget.storeId == null && widget.isDigitalPaymentActive && notHideDigital ? ListView.builder(
                    //     physics: const NeverScrollableScrollPhysics(),
                    //     shrinkWrap: true,
                    //     padding: EdgeInsets.zero,
                    //     itemCount: Get.find<SplashController>().configModel!.activePaymentMethodList!.length,
                    //     itemBuilder: (context, index) {
                    //       bool isSelected = checkoutController.paymentMethodIndex == 2 && Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay! == checkoutController.digitalPaymentName;
                    //       return InkWell(
                    //         onTap: (){
                    //           checkoutController.setPaymentMethod(2);
                    //           checkoutController.changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWay!);
                    //         },
                    //         child: Container(
                    //           decoration: BoxDecoration(
                    //               color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                    //               borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    //               border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 0.5)
                    //           ),
                    //           padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
                    //           margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                    //           child: Row(children: [
                    //             Container(
                    //               height: 20, width: 20,
                    //               decoration: BoxDecoration(
                    //                   shape: BoxShape.circle, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                    //                   border: Border.all(color: Theme.of(context).disabledColor)
                    //               ),
                    //               child: Icon(Icons.check, color: Theme.of(context).cardColor, size: 16),
                    //             ),
                    //             const SizedBox(width: Dimensions.paddingSizeDefault),
                    //
                    //             Expanded(
                    //               child: Text(
                    //                 Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayTitle!,
                    //                 style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    //                 overflow: TextOverflow.ellipsis, maxLines: 1,
                    //               ),
                    //             ),
                    //
                    //             CustomImage(
                    //               height: 20, fit: BoxFit.contain,
                    //               image: Get.find<SplashController>().configModel!.activePaymentMethodList![index].getWayImageFullUrl!,
                    //             ),
                    //             const SizedBox(width: Dimensions.paddingSizeSmall),
                    //           ]),
                    //         ),
                    //       );
                    //     }) : const SizedBox(),


                    // OfflinePaymentButton(
                    //   isSelected: checkoutController.paymentMethodIndex == 3,
                    //   offlineMethodList: checkoutController.offlineMethodList,
                    //   isOfflinePaymentActive: widget.isOfflinePaymentActive,
                    //   onTap: () {
                    //     checkoutController.setPaymentMethod(3);
                    //   },
                    //   checkoutController: checkoutController, tooltipController: tooltipController,
                    // ),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
                child: CustomButton(
                  buttonText: 'select'.tr,
                  onPressed: () => Get.back(),
                ),
              ),
            ),

          ]),
        );
      }),
    );
  }

  Widget changeAmountView(CheckoutController checkoutController) {
    return checkoutController.paymentMethodIndex == 0 ? Column(
      children: [
        showChangeAmount ? Container(
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Dimensions.paddingSizeExtraSmall, children: [

            Text('${'change_amount'.tr}(${Get.find<SplashController>().configModel?.currencySymbol})', style: robotoBold),

            Text('specify_the_amount_of_change_the_deliveryman_needs_to_bring_when_delivering_the_order'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            CustomTextField(
              // hintText: 'amount'.tr,
              titleText: 'amount'.tr,
              showLabelText: false,
              inputType: TextInputType.number,
              isAmount: true,
              inputAction: TextInputAction.done,
              controller: _amountController,
              onChanged: (String value){
                checkoutController.setExchangeAmount(double.tryParse(value)??0);
              },
            ),
          ]),
        ) : const SizedBox(),

        CustomInkWell(
          onTap: (){
            setState(() {
              showChangeAmount = !showChangeAmount;
            });
          },
          radius: Dimensions.radiusSmall,
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          child: Text(showChangeAmount ? 'see_less'.tr : 'see_more'.tr , style: robotoBold.copyWith(color: Colors.blue)),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

      ],
    ) : const SizedBox();
  }

  Widget walletView(CheckoutController checkoutController) {
    double walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance??0;
    double balance = 0;
    if(walletBalance <= 0) {
      return const SizedBox();
    }
    if(walletBalance > widget.totalPrice && checkoutController.paymentMethodIndex == 1) {
      balance = walletBalance - widget.totalPrice;
    }
    bool isWalletSelected = checkoutController.paymentMethodIndex == 1 || checkoutController.isPartialPay;

    return Get.find<SplashController>().configModel!.partialPaymentStatus!
        && Get.find<SplashController>().configModel!.customerWalletStatus == 1
        && Get.find<ProfileController>().userInfoModel != null && (checkoutController.distance != -1)
        && Get.find<ProfileController>().userInfoModel!.walletBalance! > 0 ? Column(children: [
      Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).disabledColor, width: 0.3),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(isWalletSelected ? 'wallet_remaining_balance'.tr : 'wallet_balance'.tr, style: robotoMedium.copyWith(fontSize: 12, color: Colors.grey.shade700)),

            Row(children: [
              Text(
                PriceConverter.convertPrice(isWalletSelected ? balance : walletBalance),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              ),

              Text(
                isWalletSelected ? ' (${'applied'.tr})' : '',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
              ),
            ])
          ]),

          CustomInkWell(
            onTap: () {
              if(isWalletSelected) {
                checkoutController.setPaymentMethod(-1);
                if(checkoutController.isPartialPay) {
                  checkoutController.changePartialPayment();
                }
              } else {
                if(checkoutController.isPartialPay) {
                  checkoutController.changePartialPayment();
                }
                checkoutController.setPaymentMethod(1);
                if(walletBalance < widget.totalPrice) {
                  checkoutController.changePartialPayment();
                }
              }
              configurePartialPayment();
            },
            radius: 5,
            child: isWalletSelected ? const Icon(Icons.clear, color: Colors.red) : Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Theme.of(context).primaryColor, width: 1)),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              child: Text('apply'.tr, style: robotoMedium.copyWith(fontSize: 12, color: Theme.of(context).primaryColor)),
            ),
          ),
        ]),
      ),

      if(isWalletSelected && !checkoutController.isPartialPay)
        Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            Text('paid_by_wallet'.tr, style: robotoBold.copyWith(fontSize: 14)),
            Text(PriceConverter.convertPrice(widget.totalPrice), style: robotoMedium.copyWith(fontSize: 18))

          ]),
        ),


      if(isWalletSelected && checkoutController.isPartialPay)
        Column(children: [
          Container(
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Column(children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Text('paid_by_wallet'.tr, style: robotoMedium.copyWith(fontSize: 14, color: Colors.grey.shade700)),
                Text(PriceConverter.convertPrice(walletBalance), style: robotoMedium.copyWith(fontSize: 14, color: Colors.grey.shade700))

              ]),
              const SizedBox(height: 5),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Text('remaining_bill'.tr, style: robotoMedium.copyWith(fontSize: 14)),
                Text(PriceConverter.convertPrice(widget.totalPrice - walletBalance), style: robotoBold.copyWith(fontSize: 18)),

              ])
            ]),
          ),

          if(checkoutController.paymentMethodIndex == 1)
            Text('* ${'please_select_a_option_to_pay_remain_billing_amount'.tr}', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: const Color(0xFFE74B4B))),
          const SizedBox(height: Dimensions.paddingSizeSmall),
        ]),


    ]) : const SizedBox();
  }

  Widget paymentButtonView({required String title, String? image, required bool isSelected, required Function? onTap, bool disablePayments = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: CustomInkWell(
        onTap: onTap as void Function()?,
        child: Container(
          decoration: image != null ? null : BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, width: 0.2),
          ),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(children: [

            image != null ? CustomImage(
              height: 20, fit: BoxFit.contain,
              image: image, color: disablePayments ? Theme.of(context).disabledColor : null,
            ) : const SizedBox(),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Expanded(
              child: Text(
                title,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: disablePayments ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge!.color),
              ),
            ),

            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 24,
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
            ),

          ]),

        ),
      ),
    );
  }

}
