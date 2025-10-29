import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final Color color;
  final ShopItemType type;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.color,
    required this.type,
  });
}

enum ShopItemType {
  powerUp,
  skin,
  levelPack,
}

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  PlayerInventory? _inventory;

  final List<ShopItem> _shopItems = [
    ShopItem(
      id: 'trajectory_3',
      name: 'Trajectory Hints (3x)',
      description: 'Show laser path for 3 seconds',
      price: 50,
      icon: Icons.lightbulb,
      color: const Color(0xFFFFBE0B),
      type: ShopItemType.powerUp,
    ),
    ShopItem(
      id: 'trajectory_10',
      name: 'Trajectory Hints (10x)',
      description: 'Show laser path for 3 seconds',
      price: 150,
      icon: Icons.lightbulb,
      color: const Color(0xFFFFBE0B),
      type: ShopItemType.powerUp,
    ),
    ShopItem(
      id: 'skin_neon',
      name: 'Neon Skin',
      description: 'Bright neon colors for all elements',
      price: 200,
      icon: Icons.palette,
      color: const Color(0xFFFF00FF),
      type: ShopItemType.skin,
    ),
    ShopItem(
      id: 'skin_classic',
      name: 'Classic Skin',
      description: 'Retro pixel art style',
      price: 200,
      icon: Icons.palette,
      color: const Color(0xFF00D4FF),
      type: ShopItemType.skin,
    ),
    ShopItem(
      id: 'pack_advanced_splitters',
      name: 'Advanced Splitters Pack',
      description: '10 challenging splitter levels',
      price: 300,
      icon: Icons.extension,
      color: const Color(0xFFFF9900),
      type: ShopItemType.levelPack,
    ),
    ShopItem(
      id: 'pack_portal_masters',
      name: 'Portal Masters Pack',
      description: '10 mind-bending portal levels',
      price: 300,
      icon: Icons.extension,
      color: const Color(0xFFAA00FF),
      type: ShopItemType.levelPack,
    ),
    ShopItem(
      id: 'pack_spectrum',
      name: 'Spectrum Pack',
      description: '10 color filter challenges',
      price: 300,
      icon: Icons.extension,
      color: const Color(0xFF00FF88),
      type: ShopItemType.levelPack,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    final inventory = await DatabaseService.getInventory();
    setState(() {
      _inventory = inventory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text('Shop'),
        actions: [
          if (_inventory != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E27),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.diamond, color: Color(0xFF00D4FF), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${_inventory!.crystals}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _inventory == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _shopItems.length,
              itemBuilder: (context, index) {
                final item = _shopItems[index];
                return _buildShopItemCard(item);
              },
            ),
    );
  }

  Widget _buildShopItemCard(ShopItem item) {
    final isPurchased = _isPurchased(item);
    final canAfford = _inventory!.crystals >= item.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPurchased
              ? const Color(0xFF00FF88)
              : item.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (isPurchased)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF88).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'OWNED',
                  style: TextStyle(
                    color: Color(0xFF00FF88),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: canAfford ? () => _purchaseItem(item) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.color,
                  disabledBackgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.diamond, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${item.price}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
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

  bool _isPurchased(ShopItem item) {
    switch (item.type) {
      case ShopItemType.powerUp:
        return false; // Power-ups are consumable
      case ShopItemType.skin:
        return _inventory!.purchasedSkins.contains(item.id);
      case ShopItemType.levelPack:
        return _inventory!.purchasedLevelPacks.contains(item.id);
    }
  }

  Future<void> _purchaseItem(ShopItem item) async {
    final success = await DatabaseService.spendCrystals(item.price);

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough crystals!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Update inventory based on item type
    switch (item.type) {
      case ShopItemType.powerUp:
        final charges = item.id == 'trajectory_3' ? 3 : 10;
        _inventory!.trajectoryCharges += charges;
        break;
      case ShopItemType.skin:
        _inventory!.purchasedSkins.add(item.id);
        break;
      case ShopItemType.levelPack:
        _inventory!.purchasedLevelPacks.add(item.id);
        break;
    }

    await DatabaseService.saveInventory(_inventory!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchased ${item.name}!'),
          backgroundColor: const Color(0xFF00FF88),
        ),
      );
    }

    await _loadInventory();
  }
}
