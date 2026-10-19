import 'package:flutter/material.dart';

void main() => runApp(const GateNestApp());

class GateNestApp extends StatelessWidget {
  const GateNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GateNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B5B)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
      ),
      home: const GateHomePage(),
    );
  }
}

enum UserRole { resident, guard, admin }

enum VisitorStatus { pending, approved, rejected, checkedIn, checkedOut }

class VisitorRecord {
  VisitorRecord({
    required this.name,
    required this.flat,
    required this.purpose,
    required this.createdAt,
    this.status = VisitorStatus.pending,
  });

  final String name;
  final String flat;
  final String purpose;
  final DateTime createdAt;
  VisitorStatus status;
}

class GateHomePage extends StatefulWidget {
  const GateHomePage({super.key});

  @override
  State<GateHomePage> createState() => _GateHomePageState();
}

class _GateHomePageState extends State<GateHomePage> {
  UserRole role = UserRole.guard;
  int tab = 0;
  String society = 'Green View Residency';
  final List<String> societies = [
    'Green View Residency',
    'Palm Heights',
    'Lakefront Apartments',
  ];
  final List<VisitorRecord> visitors = [
    VisitorRecord(
      name: 'Amit Sharma',
      flat: 'B-204',
      purpose: 'Guest',
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      status: VisitorStatus.pending,
    ),
    VisitorRecord(
      name: 'QuickCart delivery',
      flat: 'A-103',
      purpose: 'Delivery',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      status: VisitorStatus.approved,
    ),
  ];
  final List<String> complaints = ['Lift maintenance required — B Wing'];
  final List<String> notices = ['Water tank cleaning on Sunday, 10 AM'];

  int get pendingCount =>
      visitors.where((v) => v.status == VisitorStatus.pending).length;

  String get roleLabel => switch (role) {
        UserRole.resident => 'Resident',
        UserRole.guard => 'Security guard',
        UserRole.admin => 'Society admin',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield_moon_rounded, color: Color(0xFF176B5B)),
            SizedBox(width: 8),
            Text('GateNest', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Choose demo society',
            onSelected: (value) => setState(() => society = value),
            itemBuilder: (context) => societies
                .map((s) => PopupMenuItem(value: s, child: Text(s)))
                .toList(),
            icon: const Icon(Icons.apartment),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: tab,
          children: [
            _dashboard(),
            _visitorsPage(),
            _communityPage(),
            _adminPage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.door_front_door_outlined), selectedIcon: Icon(Icons.door_front_door), label: 'Gate'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'Community'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }

  Widget _dashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF176B5B), Color(0xFF238A72)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SOCIETY WORKSPACE', style: TextStyle(color: Colors.white70, letterSpacing: 1.2, fontSize: 11)),
              const SizedBox(height: 8),
              Text(society, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.account_circle, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Signed in as $roleLabel (demo)', style: const TextStyle(color: Colors.white))),
                  PopupMenuButton<UserRole>(
                    iconColor: Colors.white,
                    onSelected: (v) => setState(() => role = v),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: UserRole.resident, child: Text('Resident view')),
                      PopupMenuItem(value: UserRole.guard, child: Text('Guard view')),
                      PopupMenuItem(value: UserRole.admin, child: Text('Admin view')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _statCard('Pending approvals', '$pendingCount', Icons.pending_actions, const Color(0xFFFFF0D7)),
            _statCard('Visitor records', '${visitors.length}', Icons.groups_2_outlined, const Color(0xFFDDF4EC)),
            _statCard('Open complaints', '${complaints.length}', Icons.support_agent, const Color(0xFFE8E5FF)),
            _statCard('Notices', '${notices.length}', Icons.campaign_outlined, const Color(0xFFE0EDFF)),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Quick actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(onPressed: _showAddVisitor, icon: const Icon(Icons.person_add_alt_1), label: const Text('Add visitor')),
            OutlinedButton.icon(onPressed: _showAttendance, icon: const Icon(Icons.fingerprint), label: const Text('Guard attendance')),
            OutlinedButton.icon(onPressed: _showAddNotice, icon: const Icon(Icons.campaign), label: const Text('Add notice')),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Recent gate activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...visitors.take(3).map(_visitorTile),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFF24443D)),
          Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _visitorsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(child: Text('Gate register', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold))),
            FilledButton.icon(onPressed: _showAddVisitor, icon: const Icon(Icons.add), label: const Text('New')),
          ],
        ),
        const SizedBox(height: 6),
        const Text('Demo data only. Connect authentication and a cloud database before real use.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 14),
        if (visitors.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No visitors yet'))))
        else
          ...visitors.map(_visitorTile),
      ],
    );
  }

  Widget _visitorTile(VisitorRecord visitor) {
    final status = switch (visitor.status) {
      VisitorStatus.pending => 'Pending approval',
      VisitorStatus.approved => 'Approved',
      VisitorStatus.rejected => 'Rejected',
      VisitorStatus.checkedIn => 'Checked in',
      VisitorStatus.checkedOut => 'Checked out',
    };
    final color = switch (visitor.status) {
      VisitorStatus.pending => Colors.orange,
      VisitorStatus.approved => Colors.green,
      VisitorStatus.rejected => Colors.red,
      VisitorStatus.checkedIn => Colors.blue,
      VisitorStatus.checkedOut => Colors.grey,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(child: Icon(visitor.purpose == 'Delivery' ? Icons.inventory_2_outlined : Icons.person_outline)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(visitor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${visitor.purpose} • Flat ${visitor.flat}'),
                Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
            if (visitor.status == VisitorStatus.pending && role != UserRole.guard)
              PopupMenuButton<String>(
                onSelected: (v) => setState(() => visitor.status = v == 'approve' ? VisitorStatus.approved : VisitorStatus.rejected),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'approve', child: Text('Approve')),
                  PopupMenuItem(value: 'reject', child: Text('Reject')),
                ],
              )
            else if (visitor.status == VisitorStatus.pending)
              IconButton(
                tooltip: 'Mark as entered (demo)',
                onPressed: () => setState(() => visitor.status = VisitorStatus.checkedIn),
                icon: const Icon(Icons.login),
              )
            else if (visitor.status == VisitorStatus.checkedIn)
              IconButton(
                tooltip: 'Mark exit',
                onPressed: () => setState(() => visitor.status = VisitorStatus.checkedOut),
                icon: const Icon(Icons.logout),
              ),
          ],
        ),
      ),
    );
  }

  Widget _communityPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          const Expanded(child: Text('Community', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold))),
          IconButton(onPressed: _showAddNotice, icon: const Icon(Icons.add_circle_outline), tooltip: 'Add notice'),
        ]),
        const SizedBox(height: 8),
        const Text('Society notices', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ...notices.map((n) => Card(child: ListTile(leading: const Icon(Icons.campaign_outlined), title: Text(n)))),
        const SizedBox(height: 16),
        Row(children: [
          const Expanded(child: Text('Complaints', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
          TextButton.icon(onPressed: _showAddComplaint, icon: const Icon(Icons.add), label: const Text('Raise')),
        ]),
        ...complaints.map((c) => Card(child: ListTile(leading: const Icon(Icons.report_problem_outlined), title: Text(c), subtitle: const Text('Status: Open')))),
      ],
    );
  }

  Widget _adminPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Society administration', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Switch the active demo society from the building icon in the top bar. Each society will need isolated data and permissions in the production backend.'),
        const SizedBox(height: 14),
        ...societies.map((s) => Card(
          child: ListTile(
            leading: const Icon(Icons.apartment),
            title: Text(s),
            subtitle: Text(s == society ? 'Selected demo society' : 'Demo society'),
            trailing: s == society ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.chevron_right),
            onTap: () => setState(() => society = s),
          ),
        )),
        const SizedBox(height: 16),
        Card(
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Production checklist', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Secure login and role permissions'),
              Text('• Cloud database with society-level isolation'),
              Text('• Real push notifications'),
              Text('• Privacy policy and data retention rules'),
              Text('• Backup, audit log, and release signing'),
            ]),
          ),
        ),
      ],
    );
  }

  void _showAddVisitor() {
    final nameController = TextEditingController();
    final flatController = TextEditingController();
    String purpose = 'Guest';
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Register visitor'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Visitor / delivery name')),
              TextField(controller: flatController, decoration: const InputDecoration(labelText: 'Flat number')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: purpose,
                decoration: const InputDecoration(labelText: 'Purpose'),
                items: const [
                  DropdownMenuItem(value: 'Guest', child: Text('Guest')),
                  DropdownMenuItem(value: 'Delivery', child: Text('Delivery')),
                  DropdownMenuItem(value: 'Service', child: Text('Domestic help / service')),
                ],
                onChanged: (v) => setDialogState(() => purpose = v ?? 'Guest'),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty || flatController.text.trim().isEmpty) return;
                setState(() => visitors.insert(0, VisitorRecord(
                  name: nameController.text.trim(),
                  flat: flatController.text.trim(),
                  purpose: purpose,
                  createdAt: DateTime.now(),
                  status: VisitorStatus.pending,
                )));
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddComplaint() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Raise complaint'),
        content: TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(hintText: 'Describe the issue')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (controller.text.trim().isNotEmpty) setState(() => complaints.insert(0, controller.text.trim()));
            Navigator.pop(dialogContext);
          }, child: const Text('Submit')),
        ],
      ),
    );
  }

  void _showAddNotice() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add society notice'),
        content: TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(hintText: 'Write a notice')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (controller.text.trim().isNotEmpty) setState(() => notices.insert(0, controller.text.trim()));
            Navigator.pop(dialogContext);
          }, child: const Text('Publish')),
        ],
      ),
    );
  }

  void _showAttendance() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Guard attendance'),
        content: const Text('Demo attendance action. In production, record the authenticated guard ID, timestamp, society ID, and optional location under a clear privacy policy.'),
        actions: [FilledButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Got it'))],
      ),
    );
  }
}
