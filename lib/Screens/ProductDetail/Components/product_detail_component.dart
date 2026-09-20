import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carts_app/Models/product_detail_model.dart';
import 'package:carts_app/Utils/appcolors.dart';
import 'package:carts_app/Widgets/custom_image.dart';
import '../Controllers/price_comparison_controller.dart';

class ProductDetailComponent extends StatefulWidget {
  final ProductDetailModel product;
  const ProductDetailComponent({super.key, required this.product});

  @override
  State<ProductDetailComponent> createState() => _ProductDetailComponentState();
}

class _ProductDetailComponentState extends State<ProductDetailComponent> {
  late String productThumb;

  @override
  void initState() {
    super.initState();
    productThumb = widget.product.data!.images!.isEmpty
        ? ""
        : widget.product.data!.images![0].image!;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final controller = Get.put(PriceComparisonController());

    // Load price comparisons when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPriceComparisons(widget.product.data!);
    });

    return SingleChildScrollView(
      child: Column(
        children: [
          // Product Details Section with Price Comparison Integrated
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Section (Image + Details) - Compact & Centered
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Product Image (Compact)
                      Container(
                        height: 130,
                        width: 130,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: widget.product.data?.images != null &&
                                widget.product.data!.images!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CustomImage(
                                  image:
                                      widget.product.data!.images!.first.image ??
                                          '',
                                  imgHeight: 130,
                                  imgWidth: 130,
                                  boxFit: BoxFit.contain,
                                ),
                              )
                            : Icon(Icons.image,
                                size: 40, color: Colors.grey.shade400),
                      ),

                      const SizedBox(width: 16),

                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Category / Brand Name
                            if (widget.product.data?.product?.category?.name != null &&
                                widget.product.data!.product!.category!.name!.isNotEmpty)
                              Text(
                                widget.product.data!.product!.category!.name!,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),

                            const SizedBox(height: 6),

                            // Product Title
                            Text(
                              widget.product.data?.title ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 8),

                            // Rating
                            if (widget.product.data?.rating != null && widget.product.data!.rating! > 0)
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          widget.product.data!.rating!.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                  if (widget.product.data?.reviews != null &&
                                      widget.product.data!.reviews!.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      "(${widget.product.data!.reviews!.length} reviews)",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                            const SizedBox(height: 10),

                            // Features / Attributes dynamically loaded from backend
                            if (widget.product.data?.values != null &&
                                widget.product.data!.values!.isNotEmpty)
                              ...widget.product.data!.values!
                                  .where((v) => v.value?.attributeValue != null &&
                                      v.value!.attributeValue!.isNotEmpty)
                                  .take(3)
                                  .map((v) => featureRow(
                                        Icons.check_circle,
                                        v.value!.attributeValue!,
                                      ))
                            else if (widget.product.data?.product?.features != null &&
                                widget.product.data!.product!.features!.isNotEmpty)
                              ...widget.product.data!.product!.features!
                                  .where((f) => f.feature != null && f.feature!.isNotEmpty)
                                  .take(3)
                                  .map((f) => featureRow(
                                        Icons.check_circle,
                                        f.feature!,
                                      )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Compare Prices Section Centered
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Compare Prices",
                        style: GoogleFonts.mukta(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Find the best price for your product",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Dynamic Price Cards (Integrated Directly)
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return Column(
                    children: controller.priceComparisons.map((comparison) {
                      final bool hasLivePrice = comparison.price > 0;
                      return priceCard(
                        title: comparison.storeName,
                        logoUrl: comparison.logoUrl,
                        price: hasLivePrice
                            ? "₹${comparison.price.toStringAsFixed(0)}"
                            : "Check Live Price",
                        originalPrice: (hasLivePrice &&
                                comparison.originalPrice > comparison.price)
                            ? "₹${comparison.originalPrice.toStringAsFixed(0)}"
                            : null,
                        buttonColor: _getStoreColor(comparison.storeName),
                        buttonText: "Buy",
                        deliveryTime: comparison.deliveryTime,
                        discountPercentage:
                            (hasLivePrice && comparison.discountPercentage > 0)
                                ? comparison.discountPercentage
                                : null,
                        onTap: () => controller.launchStoreUrl(
                          comparison.storeName,
                          comparison.storeUrl,
                        ),
                      );
                    }).toList(),
                  );
                }),

                const SizedBox(height: 12),

                // Disclaimer
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      "Prices may vary. Please check the final price on the partner site.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: Colors.green.shade600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStoreColor(String storeName) {
    switch (storeName.toLowerCase()) {
      case 'amazon':
        return const Color(0xFFFF9900);
      case 'flipkart':
        return const Color(0xFF2874F0);
      case 'meesho':
        return const Color(0xFFF43397);
      case 'ajio':
        return const Color(0xFF2C4152);
      case 'myntra':
        return const Color(0xFFE42529);
      case 'shopsy':
        return const Color(0xFF00A389);
      default:
        return Colors.grey.shade800;
    }
  }

  Widget priceCard({
    required String title,
    required String logoUrl,
    required String price,
    String? originalPrice,
    required Color buttonColor,
    required String buttonText,
    String? deliveryTime,
    double? discountPercentage,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Store Logo
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                logoUrl.isNotEmpty ? logoUrl : 'assets/images/$title.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.store, size: 28, color: Colors.grey.shade400);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Prices and Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.mukta(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (originalPrice != null)
                      Text(
                        originalPrice,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          height: 1.1,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (originalPrice != null && discountPercentage != null)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "${discountPercentage.toStringAsFixed(0)}% OFF",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        deliveryTime ?? "FREE delivery",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Buy Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              minimumSize: const Size(80, 44),
              elevation: 0,
            ),
            onPressed: onTap,
            child: Text(
              buttonText,
              style: GoogleFonts.mukta(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
