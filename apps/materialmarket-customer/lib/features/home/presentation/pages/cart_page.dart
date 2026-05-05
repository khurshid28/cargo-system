import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../cart/data/cart_store.dart';
import '../../../orders/data/orders_remote_data_source.dart';

final _money = NumberFormat.currency(locale: 'uz', symbol: 'so‘m', decimalDigits: 0);

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _placing = false;

  Future<void> _checkout() async {
    final cart = sl<CartStore>();
    if (cart.count == 0) return;
    final addr = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final ctrl = TextEditingController(text: 'Toshkent, Yashnobod tumani, ');
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const Text('Yetkazib berish manzili', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: ctrl, maxLines: 2, decoration: const InputDecoration(
              hintText: 'Manzil', prefixIcon: Icon(Iconsax.location_copy))),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              icon: const Icon(Iconsax.tick_circle),
              label: const Text('Buyurtmani tasdiqlash'),
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            )),
          ]),
        );
      },
    );
    if (addr == null || addr.isEmpty) return;
    setState(() => _placing = true);
    try {
      await sl<OrdersRemoteDataSource>().create(
        address: addr,
        lat: 41.3111, lng: 69.2797,
        items: cart.items.map((it) => {
              'productId': it.product.id,
              'quantity': it.qty,
              'unitPrice': it.product.price,
            }).toList(),
      );
      cart.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buyurtma yaratildi! Buyurtmalar bo‘limidan kuzating.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xato: $e')));
      }
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = sl<CartStore>();
    return AnimatedBuilder(
      animation: cart,
      builder: (_, __) {
        if (cart.count == 0) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Iconsax.shopping_cart_copy, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text('Savat bo‘sh', style: TextStyle(color: Colors.black54)),
            ]),
          );
        }
        return Column(children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final it = cart.items.elementAt(i);
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 64, height: 64,
                          child: CachedNetworkImage(imageUrl: it.product.photo, fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(it.product.nameUz, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('${_money.format(it.product.price)}/${it.product.unit}',
                                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(children: [
                              IconButton(visualDensity: VisualDensity.compact,
                                icon: const Icon(Iconsax.minus_cirlce_copy),
                                onPressed: () => cart.setQty(it.product.id, it.qty - 1)),
                              Text(it.qty.toStringAsFixed(it.qty.truncate() == it.qty ? 0 : 1)),
                              IconButton(visualDensity: VisualDensity.compact,
                                icon: const Icon(Iconsax.add_circle_copy),
                                onPressed: () => cart.setQty(it.product.id, it.qty + 1)),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Iconsax.trash, color: Colors.redAccent),
                                onPressed: () => cart.remove(it.product.id),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ]),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2)),
            ]),
            child: SafeArea(
              top: false,
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Jami', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  Text(_money.format(cart.total),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ])),
                ElevatedButton.icon(
                  onPressed: _placing ? null : _checkout,
                  icon: _placing
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Iconsax.bag_tick_copy),
                  label: const Text('Buyurtma berish'),
                ),
              ]),
            ),
          ),
        ]);
      },
    );
  }
}
