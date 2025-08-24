import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cence_app/features/stock_tracking/application/inventory_notifier.dart';
import 'package:cence_app/features/stock_tracking/presentation/providers/filtered_devices_provider.dart';
import 'package:cence_app/features/stock_tracking/presentation/providers/filtered_parts_provider.dart';

class StokTakibiScreen extends ConsumerWidget {
  const StokTakibiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final state = inventoryAsync.valueOrNull;
    final selectedIndex = state?.selectedTabIndex ?? 0;
    final showOnlyCritical = state?.showOnlyCritical ?? false;

    return DefaultTabController(
      length: 2,
      initialIndex: selectedIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stok Takibi'),
          bottom: TabBar(
            onTap: (i) => ref.read(inventoryProvider.notifier).setTab(i),
            tabs: const [
              Tab(text: 'Cihazlar'),
              Tab(text: 'Parçalar'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: selectedIndex == 0
                      ? 'Cihaz model / seri no ara'
                      : 'Parça adı / kodu ara',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) {
                  if (selectedIndex == 0) {
                    ref.read(inventoryProvider.notifier).setDeviceSearch(val);
                  } else {
                    ref.read(inventoryProvider.notifier).setPartSearch(val);
                  }
                },
              ),
            ),
            if (selectedIndex == 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Sadece kritik parçalar'),
                    Switch.adaptive(
                      value: showOnlyCritical,
                      onChanged: (_) => ref
                          .read(inventoryProvider.notifier)
                          .toggleShowOnlyCritical(),
                    ),
                  ],
                ),
              ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: const [
                  _DeviceListView(),
                  _PartListView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceListView extends ConsumerWidget {
  const _DeviceListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(filteredDevicesProvider);
    return devicesAsync.when(
      data: (devices) {
        if (devices.isEmpty) {
          return const Center(child: Text('Kayıtlı cihaz bulunamadı'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: devices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final d = devices[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.devices_other),
                title: Text(d.modelName),
                subtitle: Text('#${d.serialNumber} — ${d.customer}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Cihazlar yüklenirken hata oluştu: $e'),
        ),
      ),
    );
  }
}

class _PartListView extends ConsumerWidget {
  const _PartListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partsAsync = ref.watch(filteredPartsProvider);
    return partsAsync.when(
      data: (parts) {
        if (parts.isEmpty) {
          return const Center(child: Text('Parça bulunamadı'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: parts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final p = parts[index];
            final isCritical = p.stokAdedi <= p.criticalLevel;
            return Card(
              child: ListTile(
                leading: Icon(
                  Icons.inventory_2_outlined,
                  color: isCritical ? Colors.redAccent : null,
                ),
                title: Text(p.parcaAdi),
                subtitle: Text('${p.parcaKodu} • Stok: ${p.stokAdedi}'),
                trailing: isCritical
                    ? const Chip(
                        label: Text('Kritik'),
                        backgroundColor: Color(0xFFFFE5E5),
                        labelStyle: TextStyle(color: Colors.redAccent),
                      )
                    : null,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Parçalar yüklenirken hata oluştu: $e'),
        ),
      ),
    );
  }
}
