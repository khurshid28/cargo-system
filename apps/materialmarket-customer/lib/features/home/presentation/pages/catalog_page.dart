import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../cart/data/cart_store.dart';
import '../../../catalog/data/catalog_remote_data_source.dart';

final _money = NumberFormat.currency(locale: 'uz', symbol: 'so‘m', decimalDigits: 0);

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String? _categoryId;
  String _query = '';
  // Filter state
  RangeValues _priceRange = const RangeValues(0, 5000000);
  String _sort = 'default';

  final _searchCtrl = TextEditingController();

  Future<List<Category>> get _catsF => sl<CatalogRemoteDataSource>().categories();
  Future<List<Product>> get _prodsF =>
      sl<CatalogRemoteDataSource>().products(categoryId: _categoryId, q: _query);

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Narx oralig‘i', style: TextStyle(fontWeight: FontWeight.w600)),
              RangeSlider(
                values: _priceRange,
                min: 0, max: 5000000, divisions: 50,
                labels: RangeLabels(
                  _money.format(_priceRange.start.toInt()),
                  _money.format(_priceRange.end.toInt()),
                ),
                onChanged: (v) => setSheet(() => _priceRange = v),
              ),
              const SizedBox(height: 8),
              const Text('Saralash', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (final s in const [
                  ('default', 'Standart'),
                  ('price_asc', 'Narx ↑'),
                  ('price_desc', 'Narx ↓'),
                ])
                  ChoiceChip(
                    label: Text(s.$2),
                    selected: _sort == s.$1,
                    onSelected: (_) => setSheet(() => _sort = s.$1),
                  ),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Iconsax.tick_circle),
                  label: const Text('Qo‘llash'),
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onSubmitted: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Qidiruv: g‘isht, ko‘mir...',
                  prefixIcon: const Icon(Iconsax.search_normal_1_copy),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Iconsax.close_circle_copy),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _openFilter,
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(Iconsax.filter_copy),
                ),
              ),
            ),
          ]),
        ),
        // Categories
        SizedBox(
          height: 100,
          child: FutureBuilder<List<Category>>(
            future: _catsF,
            builder: (_, snap) {
              if (!snap.hasData) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, __) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                );
              }
              final cats = snap.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: cats.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return _CatChip(
                      icon: '🌐', name: 'Hammasi',
                      selected: _categoryId == null,
                      onTap: () => setState(() => _categoryId = null),
                    );
                  }
                  final c = cats[i - 1];
                  return _CatChip(
                    icon: c.icon, name: c.nameUz,
                    selected: _categoryId == c.id,
                    onTap: () => setState(() => _categoryId = c.id),
                  );
                },
              );
            },
          ),
        ),
        // Products grid
        Expanded(
          child: FutureBuilder<List<Product>>(
            future: _prodsF,
            builder: (_, snap) {
              if (!snap.hasData) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.65,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, __) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                  ),
                );
              }
              var items = (snap.data ?? const <Product>[]).where((p) =>
                  p.price >= _priceRange.start && p.price <= _priceRange.end).toList();
              if (_sort == 'price_asc') items.sort((a, b) => a.price.compareTo(b.price));
              if (_sort == 'price_desc') items.sort((a, b) => b.price.compareTo(a.price));
              if (items.isEmpty) {
                return const Center(child: Text('Mahsulot topilmadi', style: TextStyle(color: Colors.black54)));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.65,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) => _ProductCard(p: items[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({required this.icon, required this.name, required this.selected, required this.onTap});
  final String icon; final String name; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 84,
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.p});
  final Product p;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: p.photo,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey.shade100),
                  errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Iconsax.gallery_slash_copy)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nameUz, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(p.merchantName, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text('${_money.format(p.price)}/${p.unit}',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton.icon(
                  icon: const Icon(Iconsax.add, size: 16),
                  label: const Text('Savatga'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(32),
                    padding: EdgeInsets.zero,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () {
                    sl<CartStore>().add(p);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${p.nameUz} savatga qo‘shildi'), duration: const Duration(seconds: 1)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
