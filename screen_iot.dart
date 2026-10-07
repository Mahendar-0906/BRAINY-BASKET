import 'package:flutter/material.dart';
import 'state.dart';
import 'widgets.dart';

class IoTScreen extends StatefulWidget {
  const IoTScreen({super.key, required this.state});
  final AppState state;
  @override State<IoTScreen> createState() => _IoTScreenState();
}

class _IoTScreenState extends State<IoTScreen> {
  @override
  Widget build(BuildContext context) => PageScaffold(
        title: 'IoT Monitoring',
        subtitle: 'Smart kitchen device management',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Demo mode toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: state.demoMode ? const Color(0xfffff3cd) : kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: state.demoMode ? const Color(0xffffc107).withOpacity(0.4) : const Color(0xffe0e0e0))),
            child: Row(children: [
              Icon(Icons.play_circle_outline, color: state.demoMode ? const Color(0xff856404) : const Color(0xff7a8a85), size: 22),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Demo Mode', style: TextStyle(fontWeight: FontWeight.w800, color: state.demoMode ? const Color(0xff856404) : Colors.black87)),
                Text(state.demoMode ? 'Simulation controls are active.' : 'Enable to simulate IoT events.', style: const TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
              ])),
              Switch(value: state.demoMode, onChanged: (v) { state.demoMode = v; state.notifyListeners(); setState(() {}); }, activeColor: kGreen),
            ]),
          ),
          const SizedBox(height: 20),

          // Devices
          const SectionHeader('Connected Devices'),
          const SizedBox(height: 12),
          ...state.iotDevices.map((device) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: device.online ? kGreenLight : kRedLight, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.sensors, color: device.online ? kGreen : kRed, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(device.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text('Last sync: ${_timeSince(device.lastSync)}', style: const TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: device.online ? kGreenLight : kRedLight, borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.circle, size: 8, color: device.online ? kGreen : kRed),
                const SizedBox(width: 4),
                Text(device.online ? 'ONLINE' : 'OFFLINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: device.online ? kGreen : kRed)),
              ])),
            ]),
          )),
          const SizedBox(height: 20),

          // Simulation controls
          const SectionHeader('Simulation Controls'),
          const SizedBox(height: 4),
          const Text('Simulate real-world IoT events to test the full workflow.', style: TextStyle(fontSize: 12, color: Color(0xff7a8a85))),
          const SizedBox(height: 14),
          _simButton(context, Icons.add_circle_outline, 'Simulate Grocery Added', 'Restocks a low/out-of-stock item', kGreen, () { state.simulateGroceryAdded(); _snack(context, 'Grocery restocked via IoT.', kGreen); }),
          _simButton(context, Icons.remove_circle_outline, 'Simulate Grocery Consumed', 'Decreases an item quantity', kBlue, () { state.simulateGroceryConsumed(); _snack(context, 'Grocery consumed — inventory updated.', kBlue); }),
          _simButton(context, Icons.warning_amber_rounded, 'Simulate Low Stock', 'Sets an item to minimum level', kOrange, () { state.simulateLowStock(); _snack(context, 'Low stock alert triggered.', kOrange); }),
          _simButton(context, Icons.error_outline, 'Simulate Out of Stock', 'Sets an item quantity to zero', kRed, () { state.simulateOutOfStock(); _snack(context, 'Out of stock event triggered.', kRed); }),
          _simButton(context, Icons.sync, 'Simulate IoT Inventory Update', 'Syncs all device data', kGreen, () { state.simulateIoTUpdate(); _snack(context, 'IoT inventory sync complete.', kGreen); }),
          _simButton(context, Icons.wifi_off, 'Simulate IoT Disconnect', 'Takes devices offline', kRed, () { state.simulateDisconnect(); setState(() {}); _snack(context, 'IoT device disconnected.', kRed); }),
          _simButton(context, Icons.wifi, 'Simulate IoT Reconnect', 'Brings devices back online', kGreen, () { state.simulateReconnect(); setState(() {}); _snack(context, 'IoT device reconnected.', kGreen); }),
          const SizedBox(height: 20),

          // Activity feed
          const SectionHeader('IoT Activity Log'),
          const SizedBox(height: 12),
          ...state.activity.where((a) => a.message.toLowerCase().contains('iot')).take(6).map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(entry.icon, size: 16, color: entry.color),
              const SizedBox(width: 10),
              Expanded(child: Text(entry.message, style: const TextStyle(fontSize: 13))),
              Text('${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 11, color: Color(0xff7a8a85))),
            ]),
          )),
        ]),
      );

  AppState get state => widget.state;

  Widget _simButton(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xff7a8a85))),
            ])),
            Icon(Icons.play_arrow_rounded, color: color, size: 20),
          ]),
        ),
      );

  String _timeSince(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds} sec ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    return '${diff.inHours}h ago';
  }

  void _snack(BuildContext context, String msg, Color color) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
}
