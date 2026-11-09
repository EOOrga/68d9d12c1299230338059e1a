import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bool screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

const String appTitle = 'FOYER RURAL ST BONNET DE TRONC';
const String companyName = 'FOYER RURAL ST BONNET DE TRONCAIS';
const String supportEmail = 'contact@foyerruralstbonnet.fr';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = screenshotMode
      ? AppStore.seeded(readOnly: true)
      : await AppStore.load();
  runApp(FoyerApp(store: store));
}

class FoyerApp extends StatelessWidget {
  const FoyerApp({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF261FFF);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xff24526f),
          secondary: const Color(0xff8a5d2d),
          tertiary: const Color(0xff2d7a62),
          surface: const Color(0xfff7f9fb),
          error: const Color(0xffb42318),
        );

    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xfff4f7f9),
        appBarTheme: const AppBarTheme(centerTitle: false),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xffdbe3ea)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: HomeShell(store: store),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.store});

  final AppStore store;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = [
    'Operations',
    'Records',
    'Assets',
    'Revenue',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      OverviewPage(store: widget.store),
      RecordsPage(store: widget.store),
      AssetsPage(store: widget.store),
      RevenuePage(store: widget.store),
      SettingsPage(store: widget.store),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Image.asset('docs/icon.png', width: 34, height: 34),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      floatingActionButton: switch (_index) {
        1 => FloatingActionButton.extended(
          key: const Key('new-record-button'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RecordFormPage(store: widget.store),
            ),
          ),
          icon: const Icon(Icons.note_add_outlined),
          label: const Text('New record'),
        ),
        3 => FloatingActionButton.extended(
          key: const Key('new-revenue-button'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RevenueFormPage(store: widget.store),
            ),
          ),
          icon: const Icon(Icons.add_chart_outlined),
          label: const Text('Add entry'),
        ),
        _ => null,
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_ind_outlined),
            selectedIcon: Icon(Icons.assignment_ind),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Assets',
          ),
          NavigationDestination(
            icon: Icon(Icons.query_stats_outlined),
            selectedIcon: Icon(Icons.query_stats),
            label: 'Revenue',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  AspectRatio(
                    aspectRatio: 1024 / 500,
                    child: Image.asset('docs/featured.png', fit: BoxFit.cover),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.black.withValues(alpha: 0.58),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          companyName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Offline daily workspace for records, assets, and takings.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SummaryTile(
                  icon: Icons.assignment_turned_in_outlined,
                  label: 'Open files',
                  value: '${store.patientFiles.length}',
                  tone: Theme.of(context).colorScheme.primary,
                ),
                SummaryTile(
                  icon: Icons.local_shipping_outlined,
                  label: 'Containers',
                  value: '${store.containerItems.length}',
                  tone: Theme.of(context).colorScheme.tertiary,
                ),
                SummaryTile(
                  icon: Icons.handyman_outlined,
                  label: 'Checked out',
                  value: '${store.checkedOutEquipment}',
                  tone: Theme.of(context).colorScheme.secondary,
                ),
                SummaryTile(
                  icon: Icons.payments_outlined,
                  label: 'Month',
                  value: '${store.monthlyRevenue.toStringAsFixed(0)} EUR',
                  tone: const Color(0xff51606f),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'FOYER RURAL ST BONNET DE TRONC',
              action: '${store.attentionCount} need review',
            ),
            const SizedBox(height: 8),
            ...store.todayFocus.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: WorkCard(item: item),
              ),
            ),
          ],
        );
      },
    );
  }
}

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          itemCount: store.patientFiles.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const InfoBanner(
                icon: Icons.lock_outline,
                title: 'Local records only',
                body:
                    'Patient and visitor notes stay on this device with no account, sync, or external service.',
              );
            }
            final record = store.patientFiles[index - 1];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                leading: StatusDot(status: record.status),
                title: Text(
                  record.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('${record.concern}\nNext: ${record.nextAction}'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PatientDetailPage(record: record),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PatientDetailPage extends StatelessWidget {
  const PatientDetailPage({super.key, required this.record});

  final PatientFile record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(record.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DetailHeader(
            icon: Icons.assignment_ind_outlined,
            title: record.name,
            subtitle: record.status,
          ),
          const SizedBox(height: 14),
          DetailRow(label: 'Concern', value: record.concern),
          DetailRow(label: 'Last visit', value: formatDate(record.lastVisit)),
          DetailRow(label: 'Next action', value: record.nextAction),
          const SizedBox(height: 12),
          const InfoBanner(
            icon: Icons.health_and_safety_outlined,
            title: 'Privacy posture',
            body:
                'This record is stored locally. It is not uploaded, shared, or linked to an account.',
          ),
        ],
      ),
    );
  }
}

class RecordFormPage extends StatefulWidget {
  const RecordFormPage({super.key, required this.store});

  final AppStore store;

  @override
  State<RecordFormPage> createState() => _RecordFormPageState();
}

class _RecordFormPageState extends State<RecordFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _concern = TextEditingController();
  final _nextAction = TextEditingController();
  String _status = 'Scheduled';

  @override
  void dispose() {
    _name.dispose();
    _concern.dispose();
    _nextAction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New local record')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('record-name-field'),
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Person or household',
              ),
              textInputAction: TextInputAction.next,
              validator: requiredText,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('record-concern-field'),
              controller: _concern,
              decoration: const InputDecoration(labelText: 'Record topic'),
              textInputAction: TextInputAction.next,
              validator: requiredText,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('record-action-field'),
              controller: _nextAction,
              decoration: const InputDecoration(labelText: 'Next action'),
              validator: requiredText,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'Scheduled', child: Text('Scheduled')),
                DropdownMenuItem(
                  value: 'In progress',
                  child: Text('In progress'),
                ),
                DropdownMenuItem(
                  value: 'Needs review',
                  child: Text('Needs review'),
                ),
                DropdownMenuItem(value: 'Complete', child: Text('Complete')),
              ],
              onChanged: (value) => setState(() => _status = value ?? _status),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('save-record-button'),
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                widget.store.addPatientFile(
                  PatientFile(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    name: _name.text.trim(),
                    concern: _concern.text.trim(),
                    nextAction: _nextAction.text.trim(),
                    status: _status,
                    lastVisit: DateTime.now(),
                  ),
                );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save record'),
            ),
          ],
        ),
      ),
    );
  }
}

class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.local_shipping_outlined),
                text: 'Containers',
              ),
              Tab(icon: Icon(Icons.construction_outlined), text: 'Equipment'),
            ],
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: store,
              builder: (context, _) {
                return TabBarView(
                  children: [
                    ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                      itemCount: store.containerItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = store.containerItems[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.code,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    Chip(label: Text(item.status)),
                                  ],
                                ),
                                Text('${item.location} - ${item.route}'),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(value: item.fillLevel),
                                const SizedBox(height: 6),
                                Text(
                                  '${(item.fillLevel * 100).round()}% capacity',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                      itemCount: store.equipmentItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = store.equipmentItems[index];
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            leading: const Icon(Icons.build_circle_outlined),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${item.assignedTo}\nDue ${formatDate(item.dueDate)}',
                            ),
                            isThreeLine: true,
                            trailing: FilledButton.tonal(
                              onPressed: () => store.toggleEquipment(item.id),
                              child: Text(
                                item.status == 'Checked out'
                                    ? 'Return'
                                    : 'Checkout',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RevenuePage extends StatelessWidget {
  const RevenuePage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final maxAmount = store.revenueEntries.fold<double>(
          1,
          (max, item) => item.amount > max ? item.amount : max,
        );
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            SectionHeader(
              title: 'Revenue analytics',
              action: '${store.monthlyRevenue.toStringAsFixed(0)} EUR tracked',
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: store.revenueEntries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text('${entry.amount.toStringAsFixed(0)} EUR'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: entry.amount / maxAmount,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(height: 4),
                          Text('${entry.period} - ${entry.channel}'),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const InfoBanner(
              icon: Icons.calculate_outlined,
              title: 'Local figures',
              body:
                  'Revenue entries are saved locally for quick daily review and do not leave the phone.',
            ),
          ],
        );
      },
    );
  }
}

class RevenueFormPage extends StatefulWidget {
  const RevenueFormPage({super.key, required this.store});

  final AppStore store;

  @override
  State<RevenueFormPage> createState() => _RevenueFormPageState();
}

class _RevenueFormPageState extends State<RevenueFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _amount = TextEditingController();
  String _channel = 'Room hire';

  @override
  void dispose() {
    _label.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add revenue entry')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('revenue-label-field'),
              controller: _label,
              decoration: const InputDecoration(labelText: 'Entry label'),
              validator: requiredText,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('revenue-amount-field'),
              controller: _amount,
              decoration: const InputDecoration(labelText: 'Amount in EUR'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final parsed = double.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) {
                  return 'Enter a positive amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _channel,
              decoration: const InputDecoration(labelText: 'Channel'),
              items: const [
                DropdownMenuItem(value: 'Room hire', child: Text('Room hire')),
                DropdownMenuItem(
                  value: 'Membership',
                  child: Text('Membership'),
                ),
                DropdownMenuItem(value: 'Equipment', child: Text('Equipment')),
                DropdownMenuItem(value: 'Event', child: Text('Event')),
              ],
              onChanged: (value) =>
                  setState(() => _channel = value ?? _channel),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('save-revenue-button'),
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                widget.store.addRevenueEntry(
                  RevenueEntry(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    label: _label.text.trim(),
                    amount: double.parse(_amount.text),
                    period: 'Current month',
                    channel: _channel,
                  ),
                );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save entry'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            const DetailHeader(
              icon: Icons.business_outlined,
              title: companyName,
              subtitle: 'Offline operational records',
            ),
            const SizedBox(height: 14),
            Card(
              child: SwitchListTile(
                value: store.privacyLock,
                onChanged: store.setPrivacyLock,
                secondary: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy reminder'),
                subtitle: const Text(
                  'Show local-only privacy notes in daily workflows.',
                ),
              ),
            ),
            const SizedBox(height: 10),
            const DetailRow(
              label: 'Storage',
              value: 'Device-only local storage',
            ),
            const DetailRow(
              label: 'Network use',
              value: 'No APIs, no cloud sync, no analytics',
            ),
            const DetailRow(label: 'Support', value: supportEmail),
            const SizedBox(height: 12),
            const InfoBanner(
              icon: Icons.delete_outline,
              title: 'Deletion',
              body:
                  'Uninstalling the app removes locally stored records according to Android system behavior.',
            ),
          ],
        );
      },
    );
  }
}

class SummaryTile extends StatelessWidget {
  const SummaryTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width >= 720
          ? (MediaQuery.sizeOf(context).width - 56) / 4
          : (MediaQuery.sizeOf(context).width - 44) / 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: tone),
              const SizedBox(height: 10),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          action,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }
}

class WorkCard extends StatelessWidget {
  const WorkCard({super.key, required this.item});

  final WorkItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(item.subtitle),
        trailing: Chip(label: Text(item.status)),
      ),
    );
  }
}

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Complete' => Theme.of(context).colorScheme.tertiary,
      'Needs review' => Theme.of(context).colorScheme.error,
      'In progress' => Theme.of(context).colorScheme.secondary,
      _ => Theme.of(context).colorScheme.primary,
    };
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.12),
      child: Icon(Icons.circle, color: color, size: 14),
    );
  }
}

class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 104,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? requiredText(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}

String formatDate(DateTime date) {
  const months = [
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
  return '${months[date.month - 1]} ${date.day}';
}

class AppStore extends ChangeNotifier {
  AppStore._({
    required this.patientFiles,
    required this.containerItems,
    required this.equipmentItems,
    required this.revenueEntries,
    required this.privacyLock,
    SharedPreferencesAsync? preferences,
    this.readOnly = false,
  }) : _preferences = preferences;

  static const _patientsKey = 'patients';
  static const _containersKey = 'containers';
  static const _equipmentKey = 'equipment';
  static const _revenueKey = 'revenue';
  static const _privacyLockKey = 'privacyLock';

  final SharedPreferencesAsync? _preferences;
  final bool readOnly;

  List<PatientFile> patientFiles;
  List<ContainerItem> containerItems;
  List<EquipmentItem> equipmentItems;
  List<RevenueEntry> revenueEntries;
  bool privacyLock;

  static Future<AppStore> load() async {
    final preferences = SharedPreferencesAsync();
    final seeded = AppStore.seeded(preferences: preferences);
    final patients = await preferences.getString(_patientsKey);
    final containers = await preferences.getString(_containersKey);
    final equipment = await preferences.getString(_equipmentKey);
    final revenue = await preferences.getString(_revenueKey);
    final privacyLock = await preferences.getBool(_privacyLockKey);

    return AppStore._(
      preferences: preferences,
      privacyLock: privacyLock ?? true,
      patientFiles: patients == null
          ? seeded.patientFiles
          : decodeList(patients, PatientFile.fromJson),
      containerItems: containers == null
          ? seeded.containerItems
          : decodeList(containers, ContainerItem.fromJson),
      equipmentItems: equipment == null
          ? seeded.equipmentItems
          : decodeList(equipment, EquipmentItem.fromJson),
      revenueEntries: revenue == null
          ? seeded.revenueEntries
          : decodeList(revenue, RevenueEntry.fromJson),
    );
  }

  static AppStore seeded({
    SharedPreferencesAsync? preferences,
    bool readOnly = false,
  }) {
    final now = DateTime(2026, 5, 12);
    return AppStore._(
      preferences: preferences,
      readOnly: readOnly,
      privacyLock: true,
      patientFiles: [
        PatientFile(
          id: 'p1',
          name: 'Aline Martin',
          concern: 'Medication transport assistance',
          nextAction: 'Confirm driver rota',
          status: 'Needs review',
          lastVisit: now.subtract(const Duration(days: 1)),
        ),
        PatientFile(
          id: 'p2',
          name: 'Bernard Petit',
          concern: 'Weekly wellness check',
          nextAction: 'Prepare visit sheet',
          status: 'Scheduled',
          lastVisit: now.subtract(const Duration(days: 3)),
        ),
        PatientFile(
          id: 'p3',
          name: 'Claire Bernard',
          concern: 'Community meal support',
          nextAction: 'Update dietary note',
          status: 'In progress',
          lastVisit: now.subtract(const Duration(days: 5)),
        ),
      ],
      containerItems: const [
        ContainerItem(
          id: 'c1',
          code: 'CTR-12 Supplies',
          location: 'Main hall',
          route: 'Ready for Friday event',
          fillLevel: 0.72,
          status: 'Review',
        ),
        ContainerItem(
          id: 'c2',
          code: 'CTR-18 Linen',
          location: 'Storage room',
          route: 'Return to laundry',
          fillLevel: 0.48,
          status: 'On track',
        ),
        ContainerItem(
          id: 'c3',
          code: 'CTR-21 Kitchen',
          location: 'Annex',
          route: 'Inventory count due',
          fillLevel: 0.86,
          status: 'Full soon',
        ),
      ],
      equipmentItems: [
        EquipmentItem(
          id: 'e1',
          name: 'Projector kit',
          assignedTo: 'Theatre group',
          dueDate: now.add(const Duration(days: 2)),
          status: 'Checked out',
        ),
        EquipmentItem(
          id: 'e2',
          name: 'Folding tables set',
          assignedTo: 'Available',
          dueDate: now.add(const Duration(days: 7)),
          status: 'Available',
        ),
        EquipmentItem(
          id: 'e3',
          name: 'Sound mixer',
          assignedTo: 'Choir rehearsal',
          dueDate: now.add(const Duration(days: 1)),
          status: 'Checked out',
        ),
      ],
      revenueEntries: const [
        RevenueEntry(
          id: 'r1',
          label: 'Room hire',
          amount: 1380,
          period: 'May',
          channel: 'Bookings',
        ),
        RevenueEntry(
          id: 'r2',
          label: 'Memberships',
          amount: 840,
          period: 'May',
          channel: 'Desk',
        ),
        RevenueEntry(
          id: 'r3',
          label: 'Equipment fees',
          amount: 360,
          period: 'May',
          channel: 'Checkout',
        ),
        RevenueEntry(
          id: 'r4',
          label: 'Event takings',
          amount: 1210,
          period: 'May',
          channel: 'Events',
        ),
      ],
    );
  }

  int get checkedOutEquipment =>
      equipmentItems.where((item) => item.status == 'Checked out').length;

  double get monthlyRevenue =>
      revenueEntries.fold<double>(0, (total, item) => total + item.amount);

  int get attentionCount {
    final files = patientFiles
        .where((file) => file.status == 'Needs review')
        .length;
    final containers = containerItems
        .where((item) => item.status == 'Review' || item.status == 'Full soon')
        .length;
    return files + containers + checkedOutEquipment;
  }

  List<WorkItem> get todayFocus => [
    ...patientFiles
        .where((file) => file.status == 'Needs review')
        .map(
          (file) => WorkItem(
            icon: Icons.assignment_ind_outlined,
            title: file.name,
            subtitle: file.nextAction,
            status: file.status,
          ),
        ),
    ...containerItems
        .where((item) => item.status != 'On track')
        .map(
          (item) => WorkItem(
            icon: Icons.local_shipping_outlined,
            title: item.code,
            subtitle: item.route,
            status: item.status,
          ),
        ),
    ...equipmentItems
        .where((item) => item.status == 'Checked out')
        .map(
          (item) => WorkItem(
            icon: Icons.construction_outlined,
            title: item.name,
            subtitle: '${item.assignedTo}, due ${formatDate(item.dueDate)}',
            status: item.status,
          ),
        ),
  ];

  void addPatientFile(PatientFile file) {
    patientFiles = [file, ...patientFiles];
    notifyListeners();
    _persist();
  }

  void addRevenueEntry(RevenueEntry entry) {
    revenueEntries = [entry, ...revenueEntries];
    notifyListeners();
    _persist();
  }

  void toggleEquipment(String id) {
    equipmentItems = equipmentItems.map((item) {
      if (item.id != id) {
        return item;
      }
      return item.copyWith(
        status: item.status == 'Checked out' ? 'Available' : 'Checked out',
        assignedTo: item.status == 'Checked out' ? 'Available' : 'Front desk',
      );
    }).toList();
    notifyListeners();
    _persist();
  }

  void setPrivacyLock(bool value) {
    privacyLock = value;
    notifyListeners();
    _persist();
  }

  void _persist() {
    if (readOnly || _preferences == null) {
      return;
    }
    unawaited(_save());
  }

  Future<void> _save() async {
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }
    await preferences.setString(
      _patientsKey,
      jsonEncode(patientFiles.map((item) => item.toJson()).toList()),
    );
    await preferences.setString(
      _containersKey,
      jsonEncode(containerItems.map((item) => item.toJson()).toList()),
    );
    await preferences.setString(
      _equipmentKey,
      jsonEncode(equipmentItems.map((item) => item.toJson()).toList()),
    );
    await preferences.setString(
      _revenueKey,
      jsonEncode(revenueEntries.map((item) => item.toJson()).toList()),
    );
    await preferences.setBool(_privacyLockKey, privacyLock);
  }
}

List<T> decodeList<T>(
  String source,
  T Function(Map<String, dynamic>) fromJson,
) {
  final decoded = jsonDecode(source) as List<dynamic>;
  return decoded
      .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
      .toList();
}

class WorkItem {
  const WorkItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
}

class PatientFile {
  const PatientFile({
    required this.id,
    required this.name,
    required this.concern,
    required this.nextAction,
    required this.status,
    required this.lastVisit,
  });

  final String id;
  final String name;
  final String concern;
  final String nextAction;
  final String status;
  final DateTime lastVisit;

  factory PatientFile.fromJson(Map<String, dynamic> json) {
    return PatientFile(
      id: json['id'] as String,
      name: json['name'] as String,
      concern: json['concern'] as String,
      nextAction: json['nextAction'] as String,
      status: json['status'] as String,
      lastVisit: DateTime.parse(json['lastVisit'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'concern': concern,
    'nextAction': nextAction,
    'status': status,
    'lastVisit': lastVisit.toIso8601String(),
  };
}

class ContainerItem {
  const ContainerItem({
    required this.id,
    required this.code,
    required this.location,
    required this.route,
    required this.fillLevel,
    required this.status,
  });

  final String id;
  final String code;
  final String location;
  final String route;
  final double fillLevel;
  final String status;

  factory ContainerItem.fromJson(Map<String, dynamic> json) {
    return ContainerItem(
      id: json['id'] as String,
      code: json['code'] as String,
      location: json['location'] as String,
      route: json['route'] as String,
      fillLevel: (json['fillLevel'] as num).toDouble(),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'location': location,
    'route': route,
    'fillLevel': fillLevel,
    'status': status,
  };
}

class EquipmentItem {
  const EquipmentItem({
    required this.id,
    required this.name,
    required this.assignedTo,
    required this.dueDate,
    required this.status,
  });

  final String id;
  final String name;
  final String assignedTo;
  final DateTime dueDate;
  final String status;

  EquipmentItem copyWith({String? assignedTo, String? status}) {
    return EquipmentItem(
      id: id,
      name: name,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate,
      status: status ?? this.status,
    );
  }

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      id: json['id'] as String,
      name: json['name'] as String,
      assignedTo: json['assignedTo'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'assignedTo': assignedTo,
    'dueDate': dueDate.toIso8601String(),
    'status': status,
  };
}

class RevenueEntry {
  const RevenueEntry({
    required this.id,
    required this.label,
    required this.amount,
    required this.period,
    required this.channel,
  });

  final String id;
  final String label;
  final double amount;
  final String period;
  final String channel;

  factory RevenueEntry.fromJson(Map<String, dynamic> json) {
    return RevenueEntry(
      id: json['id'] as String,
      label: json['label'] as String,
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] as String,
      channel: json['channel'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'amount': amount,
    'period': period,
    'channel': channel,
  };
}
