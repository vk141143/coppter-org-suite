import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../core/constants/brand_colors.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  String _searchQuery = '';
  
  final List<Map<String, dynamic>> _branches = [
    {
      'id': 'BR001',
      'name': 'North Dumpyard',
      'address': '123 Industrial Ave, North District',
      'capacity': '500 tons',
      'currentLoad': '320 tons',
      'status': 'Active',
      'manager': 'John Smith',
      'phone': '+1 234 567 8900',
      'operatingHours': '6:00 AM - 10:00 PM',
    },
    {
      'id': 'BR002',
      'name': 'South Recycling Center',
      'address': '456 Green Road, South District',
      'capacity': '400 tons',
      'currentLoad': '380 tons',
      'status': 'Active',
      'manager': 'Jane Doe',
      'phone': '+1 234 567 8901',
      'operatingHours': '7:00 AM - 9:00 PM',
    },
    {
      'id': 'BR003',
      'name': 'East Waste Facility',
      'address': '789 Main Street, East District',
      'capacity': '600 tons',
      'currentLoad': '150 tons',
      'status': 'Active',
      'manager': 'Bob Wilson',
      'phone': '+1 234 567 8902',
      'operatingHours': '24/7',
    },
    {
      'id': 'BR004',
      'name': 'West Collection Point',
      'address': '321 Oak Avenue, West District',
      'capacity': '300 tons',
      'currentLoad': '290 tons',
      'status': 'Maintenance',
      'manager': 'Alice Brown',
      'phone': '+1 234 567 8903',
      'operatingHours': 'Closed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(theme),
          _buildStatsCards(theme),
          _buildControls(theme),
          Expanded(child: _buildBranchesTable(theme)),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Branches', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 28)),
              const SizedBox(height: 4),
              Text('Manage dumpyard branches and collection areas', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _addBranch,
            icon: const Icon(Icons.add),
            label: const Text('Add Branch'),
            style: ElevatedButton.styleFrom(backgroundColor: BrandColors.primaryGreen, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme) {
    final active = _branches.where((b) => b['status'] == 'Active').length;
    final totalCapacity = _branches.fold(0, (sum, b) => sum + int.parse(b['capacity'].split(' ')[0]));
    final totalLoad = _branches.fold(0, (sum, b) => sum + int.parse(b['currentLoad'].split(' ')[0]));
    final utilization = ((totalLoad / totalCapacity) * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
      child: Row(
        children: [
          Expanded(child: _buildStatCard(theme, 'Total Branches', '${_branches.length}', Icons.location_on, const Color(0xFF0F5132))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(theme, 'Active', '$active', Icons.check_circle, const Color(0xFF2D7A4F))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(theme, 'Total Capacity', '$totalCapacity tons', Icons.storage, const Color(0xFF5A9F6E))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(theme, 'Utilization', '$utilization%', Icons.pie_chart, const Color(0xFF87C48D))),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, IconData icon, Color color) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: CustomCard(
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search by branch name, ID, or location...',
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildBranchesTable(ThemeData theme) {
    final filtered = _branches.where((b) {
      if (_searchQuery.isEmpty) return true;
      return b['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b['id'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b['address'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (filtered.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.location_off, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
        const SizedBox(height: 16),
        Text('No branches found', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
      ]));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: CustomCard(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(theme.colorScheme.primary.withOpacity(0.05)),
            columnSpacing: 30,
            dataRowMinHeight: 70,
            dataRowMaxHeight: 90,
            columns: const [
              DataColumn(label: Text('Branch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Manager', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Capacity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Current Load', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Hours', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            ],
            rows: filtered.map((branch) {
              final loadPercent = (int.parse(branch['currentLoad'].split(' ')[0]) / int.parse(branch['capacity'].split(' ')[0]) * 100).toInt();
              return DataRow(cells: [
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(branch['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(branch['id'], style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ],
                )),
                DataCell(SizedBox(width: 200, child: Text(branch['address'], style: const TextStyle(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis))),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(branch['manager'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(branch['phone'], style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ],
                )),
                DataCell(Text(branch['capacity'], style: const TextStyle(fontSize: 13))),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(branch['currentLoad'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('$loadPercent% full', style: TextStyle(fontSize: 11, color: loadPercent > 90 ? Colors.red : Colors.green)),
                  ],
                )),
                DataCell(Text(branch['operatingHours'], style: const TextStyle(fontSize: 12))),
                DataCell(_buildStatusBadge(branch['status'], theme)),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.visibility, size: 18, color: Color(0xFF0F5132)), onPressed: () => _viewBranch(branch), tooltip: 'View'),
                    IconButton(icon: const Icon(Icons.edit, size: 18, color: Color(0xFF0F5132)), onPressed: () => _editBranch(branch), tooltip: 'Edit'),
                    IconButton(icon: const Icon(Icons.delete, size: 18, color: Color(0xFF87C48D)), onPressed: () => _deleteBranch(branch), tooltip: 'Delete'),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color color = status == 'Active' ? const Color(0xFF0F5132) : const Color(0xFF87C48D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  void _addBranch() {
    _showBranchDialog(null);
  }

  void _editBranch(Map<String, dynamic> branch) {
    _showBranchDialog(branch);
  }

  void _showBranchDialog(Map<String, dynamic>? branch) {
    final isEdit = branch != null;
    final nameController = TextEditingController(text: branch?['name']);
    final addressController = TextEditingController(text: branch?['address']);
    final capacityController = TextEditingController(text: branch?['capacity'].split(' ')[0]);
    final managerController = TextEditingController(text: branch?['manager']);
    final phoneController = TextEditingController(text: branch?['phone']);
    final hoursController = TextEditingController(text: branch?['operatingHours']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Branch' : 'Add New Branch'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Branch Name')),
                const SizedBox(height: 12),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address'), maxLines: 2),
                const SizedBox(height: 12),
                TextField(controller: capacityController, decoration: const InputDecoration(labelText: 'Capacity (tons)', suffixText: 'tons'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: managerController, decoration: const InputDecoration(labelText: 'Manager Name')),
                const SizedBox(height: 12),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                TextField(controller: hoursController, decoration: const InputDecoration(labelText: 'Operating Hours')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (isEdit) {
                setState(() {
                  branch['name'] = nameController.text;
                  branch['address'] = addressController.text;
                  branch['capacity'] = '${capacityController.text} tons';
                  branch['manager'] = managerController.text;
                  branch['phone'] = phoneController.text;
                  branch['operatingHours'] = hoursController.text;
                });
              } else {
                setState(() {
                  _branches.add({
                    'id': 'BR00${_branches.length + 1}',
                    'name': nameController.text,
                    'address': addressController.text,
                    'capacity': '${capacityController.text} tons',
                    'currentLoad': '0 tons',
                    'status': 'Active',
                    'manager': managerController.text,
                    'phone': phoneController.text,
                    'operatingHours': hoursController.text,
                  });
                });
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isEdit ? 'Branch updated successfully' : 'Branch added successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: BrandColors.primaryGreen, foregroundColor: Colors.white),
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _viewBranch(Map<String, dynamic> branch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Branch Details - ${branch['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Branch ID', branch['id']),
              _buildDetailRow('Name', branch['name']),
              _buildDetailRow('Address', branch['address']),
              _buildDetailRow('Manager', branch['manager']),
              _buildDetailRow('Phone', branch['phone']),
              _buildDetailRow('Capacity', branch['capacity']),
              _buildDetailRow('Current Load', branch['currentLoad']),
              _buildDetailRow('Operating Hours', branch['operatingHours']),
              _buildDetailRow('Status', branch['status']),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _deleteBranch(Map<String, dynamic> branch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Branch'),
        content: Text('Are you sure you want to delete ${branch['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _branches.remove(branch));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${branch['name']} deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF87C48D), foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
