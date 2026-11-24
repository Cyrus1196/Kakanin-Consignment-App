import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database/hive_database.dart';
import '../models/consignment_entry.dart';
import '../models/product_price.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showManageProducts() {
    showDialog(
      context: context,
      builder: (dialogContext) => const _ManageProductsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kakanin Consignment'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[800]),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit_note, color: Colors.green[800]),
              title: const Text(
                'Manage Products',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                _showManageProducts();
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Kakanin Stall',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Monitor Your Products',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showManageProducts,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.brown[600],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Manage Products'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageProductsDialog extends StatelessWidget {
  const _ManageProductsDialog();

  Future<void> _showProductForm(BuildContext context, {ProductPrice? product}) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => _ProductFormDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = HiveDatabase.productPricesBox();

    return AlertDialog(
      title: const Text('Manage Products'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.55,
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<ProductPrice> box, _) {
            final products = box.values.toList()
              ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

            if (products.isEmpty) {
              return const Center(child: Text('No products yet'));
            }

            return ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(product.name),
                  subtitle: Text('₱${product.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit product',
                        onPressed: () => _showProductForm(context, product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete product',
                        onPressed: () => HiveDatabase.deleteProduct(product),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () => _showProductForm(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DecimalInputFormatter extends TextInputFormatter {
  const _DecimalInputFormatter();

  static final RegExp _pattern = RegExp(r'^\d*\.?\d{0,2}$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || _pattern.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog({this.product});

  final ProductPrice? product;

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  DateTime _selectedDate = DateTime.now();
  String? _error;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  bool get _isEdit => widget.product != null;

  String _formatDate(DateTime date) {
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product == null ? '' : widget.product!.price.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text);
    if (name.isEmpty || price == null || price <= 0) {
      setState(() => _error = 'Enter a product name and a price greater than 0.');
      return;
    }

    if (_isEdit) {
      await HiveDatabase.updateProduct(widget.product!, name, price);
    } else {
      await HiveDatabase.addProduct(name, price);
      await HiveDatabase.addConsignment(name, price, _selectedDate);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Widget _dateField() {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(_formatDate(_selectedDate)),
      ),
    );
  }

  Widget _dayList(List<ConsignmentEntry> entries) {
    final dayEntries = entries.where((entry) => _sameDay(entry.date, _selectedDate)).toList()
      ..sort(
        (a, b) => a.productName.toLowerCase().compareTo(b.productName.toLowerCase()),
      );

    if (dayEntries.isEmpty) {
      return const Center(child: Text('No products for this date'));
    }

    return ListView.separated(
      itemCount: dayEntries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = dayEntries[index];
        final total = entry.price * entry.quantity;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(entry.productName),
          subtitle: Text(
            '₱${entry.price.toStringAsFixed(2)} × ${entry.quantity} = ₱${total.toStringAsFixed(2)}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Remove',
            onPressed: () => HiveDatabase.deleteConsignment(entry),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entriesBox = HiveDatabase.consignmentsBox();

    return AlertDialog(
      title: Text(_isEdit ? 'Edit Product' : 'Add Product'),
      content: SizedBox(
        width: 360,
        child: ValueListenableBuilder(
          valueListenable: entriesBox.listenable(),
          builder: (context, Box<ConsignmentEntry> entriesBox, _) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: const [_DecimalInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: '₱',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                  if (!_isEdit) ...[
                    const SizedBox(height: 16),
                    _dateField(),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: _dayList(entriesBox.values.toList()),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
