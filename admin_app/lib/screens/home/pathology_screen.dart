import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'package:ui_components/ui_components.dart';
import '../../config/app_colors.dart';

class PathologyScreen extends StatefulWidget {
  const PathologyScreen({super.key});

  @override
  State<PathologyScreen> createState() => _PathologyScreenState();
}

class _PathologyScreenState extends State<PathologyScreen> {
  final _apiClient = OnMintApiClient();
  List<dynamic> _labs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLabs();
  }

  Future<void> _loadLabs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _apiClient.initialize();
      final response = await _apiClient.admin.getAllPathologyLabs(
        page: 1,
        limit: 20,
      );

      setState(() {
        _labs = response['pathologyLabs'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTests(String labId, List<Map<String, dynamic>> tests) async {
    try {
      await _apiClient.admin.updatePathologyTests(
        labId,
        tests,
      );

      ToastUtils.showSuccess('Tests updated successfully');
      _loadLabs();
    } catch (e) {
      ToastUtils.showError(e.toString());
    }
  }

  void _showTestsDialog(dynamic lab) {
    final tests = List<Map<String, dynamic>>.from(lab['testsOffered'] ?? []);
    
    showDialog(
      context: context,
      builder: (context) => _TestsManagementDialog(
        labName: lab['labName'] ?? lab['firstName'] ?? 'Lab',
        initialTests: tests,
        onSave: (updatedTests) {
          _updateTests(lab['_id'], updatedTests);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pathology Lab Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? CustomErrorWidget(
                  message: _error!,
                  onRetry: _loadLabs,
                )
              : _labs.isEmpty
                  ? const EmptyStateWidget(
                      title: 'No Pathology Labs',
                      message: 'No pathology labs found',
                      icon: Icons.science,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLabs,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final lab = _labs[index];
                          final tests = lab['testsOffered'] ?? [];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: const Icon(
                                  Icons.science,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(
                                lab['labName'] ?? lab['firstName'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    lab['email'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    lab['phone'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (lab['city'] != null)
                                    Text(
                                      '${lab['city']}, ${lab['state'] ?? ''}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${tests.length} tests available',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showTestsDialog(lab),
                                tooltip: 'Manage Tests',
                              ),
                              children: [
                                if (tests.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'No tests available',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: tests.length,
                                      itemBuilder: (context, idx) {
                                        final test = tests[idx];
                                        return ListTile(
                                          leading: const Icon(
                                            Icons.medical_services,
                                            size: 20,
                                          ),
                                          title: Text(
                                            test['testName'] ?? test['name'] ?? '',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: test['description'] != null
                                              ? Text(
                                                  test['description'],
                                                  style: const TextStyle(fontSize: 12),
                                                  overflow: TextOverflow.ellipsis,
                                                )
                                              : null,
                                          trailing: Text(
                                            '₹${test['price'] ?? 0}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _TestsManagementDialog extends StatefulWidget {
  final String labName;
  final List<Map<String, dynamic>> initialTests;
  final Function(List<Map<String, dynamic>>) onSave;

  const _TestsManagementDialog({
    required this.labName,
    required this.initialTests,
    required this.onSave,
  });

  @override
  State<_TestsManagementDialog> createState() => _TestsManagementDialogState();
}

class _TestsManagementDialogState extends State<_TestsManagementDialog> {
  late List<Map<String, dynamic>> _tests;

  @override
  void initState() {
    super.initState();
    _tests = List.from(widget.initialTests);
  }

  void _addTest() {
    setState(() {
      _tests.add({
        'testName': '',
        'description': '',
        'price': 0,
        'preparationRequired': false,
        'reportTime': '24 hours',
      });
    });
  }

  void _removeTest(int index) {
    setState(() {
      _tests.removeAt(index);
    });
  }

  void _showEditTestDialog(int index) {
    final test = _tests[index];
    final nameController = TextEditingController(text: test['testName'] ?? '');
    final descController = TextEditingController(text: test['description'] ?? '');
    final priceController = TextEditingController(text: (test['price'] ?? 0).toString());
    final reportTimeController = TextEditingController(text: test['reportTime'] ?? '');
    bool preparationRequired = test['preparationRequired'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text((test['testName']?.isEmpty ?? true) ? 'Add Test' : 'Edit Test'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Test Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (₹) *',
                    border: OutlineInputBorder(),
                    prefixText: '₹ ',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reportTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Report Time',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 24 hours, 2 days',
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Preparation Required'),
                  value: preparationRequired,
                  onChanged: (value) {
                    setDialogState(() {
                      preparationRequired = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty || priceController.text.isEmpty) {
                  ToastUtils.showError('Please fill required fields');
                  return;
                }

                setState(() {
                  _tests[index] = {
                    'testName': nameController.text,
                    'description': descController.text,
                    'price': double.tryParse(priceController.text) ?? 0,
                    'reportTime': reportTimeController.text,
                    'preparationRequired': preparationRequired,
                  };
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Manage Tests - ${widget.labName}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: _tests.isEmpty
                  ? const Center(
                      child: Text(
                        'No tests added yet',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _tests.length,
                      itemBuilder: (context, index) {
                        final test = _tests[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.medical_services),
                            title: Text(
                              test['testName']?.isEmpty ?? true ? 'New Test' : test['testName'],
                              style: TextStyle(
                                fontStyle: test['testName']?.isEmpty ?? true
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                            subtitle: test['price'] > 0
                                ? Text('₹${test['price']}')
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _showEditTestDialog(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  color: Colors.red,
                                  onPressed: () => _removeTest(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addTest,
              icon: const Icon(Icons.add),
              label: const Text('Add Test'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validate all tests have required fields
            final invalidTests = _tests.where(
              (test) => (test['testName']?.isEmpty ?? true) || test['price'] == 0,
            );
            
            if (invalidTests.isNotEmpty) {
              ToastUtils.showError(
                'Please complete all test details',
              );
              return;
            }

            Navigator.pop(context);
            widget.onSave(_tests);
          },
          child: const Text('Save All'),
        ),
      ],
    );
  }
}
