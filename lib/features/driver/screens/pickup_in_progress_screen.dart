import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';

class PickupInProgressScreen extends StatefulWidget {
  final String jobId;

  const PickupInProgressScreen({
    super.key,
    required this.jobId,
  });

  @override
  State<PickupInProgressScreen> createState() => _PickupInProgressScreenState();
}

class _PickupInProgressScreenState extends State<PickupInProgressScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  XFile? _completionPhoto;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'En Route',
      'description': 'Heading to pickup location',
      'icon': Icons.directions_car,
      'action': 'Mark as Reached',
    },
    {
      'title': 'At Location',
      'description': 'Arrived at customer location',
      'icon': Icons.location_on,
      'action': 'Start Pickup',
    },
    {
      'title': 'Collecting Waste',
      'description': 'Collecting waste from customer',
      'icon': Icons.delete_outline,
      'action': 'Upload Photo',
    },
    {
      'title': 'Completed',
      'description': 'Pickup completed successfully',
      'icon': Icons.check_circle,
      'action': 'Mark Complete',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Pickup ${widget.jobId}'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            // Progress Steps
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Job Info
                    _buildJobInfo(theme),
                    
                    const SizedBox(height: 24),
                    
                    // Live Map
                    _buildLiveMap(theme),
                    
                    const SizedBox(height: 24),
                    
                    // Progress Timeline
                    _buildProgressTimeline(theme),
                    
                    const SizedBox(height: 24),
                    
                    // Current Step Details
                    _buildCurrentStepDetails(theme),
                  ],
                ),
              ),
            ),
            
            // Action Button
            _buildActionButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInfo(ThemeData theme) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🏠', style: TextStyle(fontSize: 24)),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Household Waste Collection',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  '123 Main Street, Apartment 4B',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  'Customer: John Doe',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            onPressed: () {
              // Call customer
            },
            icon: Icon(
              Icons.phone,
              color: theme.colorScheme.primary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMap(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Location',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Live Tracking',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentStep == 0 ? 'En route to location' : 'At pickup location',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ETA',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        _currentStep == 0 ? '5 mins' : 'Arrived',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Distance',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        _currentStep == 0 ? '1.2 km' : '0 km',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Timeline',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Column(
            children: List.generate(_steps.length, (index) {
              final step = _steps[index];
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              final isUpcoming = index > _currentStep;
              
              return Row(
                children: [
                  // Timeline indicator
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green
                              : isCurrent
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: isCurrent
                              ? Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check
                              : step['icon'],
                          color: isUpcoming
                              ? theme.colorScheme.onSurface.withOpacity(0.5)
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                      if (index < _steps.length - 1)
                        Container(
                          width: 2,
                          height: 40,
                          color: isCompleted
                              ? Colors.green
                              : theme.colorScheme.outline.withOpacity(0.3),
                        ),
                    ],
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Step info
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'],
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isUpcoming
                                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Text(
                            step['description'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          
                          if (isCompleted)
                            Text(
                              'Completed at ${_getCompletionTime(index)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepDetails(ThemeData theme) {
    if (_currentStep >= _steps.length) return const SizedBox.shrink();
    
    final currentStepData = _steps[_currentStep];
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Step: ${currentStepData['title']}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (_currentStep == 2) ...[
            // Photo upload step
            Text(
              'Upload Completion Photo',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Take a photo of the completed pickup to confirm the job is done.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (_completionPhoto != null) ...[
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 48),
                      SizedBox(height: 8),
                      Text('Photo uploaded successfully'),
                    ],
                  ),
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.primary.withOpacity(0.05),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: theme.colorScheme.primary,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to take photo',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    currentStepData['icon'],
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      currentStepData['description'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    if (_currentStep >= _steps.length) return const SizedBox.shrink();
    
    final currentStepData = _steps[_currentStep];
    bool canProceed = true;
    
    if (_currentStep == 2 && _completionPhoto == null) {
      canProceed = false;
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: CustomButton(
        text: currentStepData['action'],
        isLoading: _isLoading,
        onPressed: canProceed ? _handleStepAction : () {},
      ),
    );
  }

  void _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    
    if (photo != null) {
      setState(() {
        _completionPhoto = photo;
      });
    }
  }

  void _handleStepAction() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (_currentStep < _steps.length - 1) {
          _currentStep++;
        } else {
          // Job completed
          _showCompletionDialog();
        }
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Job Completed!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Great job! You have successfully completed the pickup. Earnings: \$25.00',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Back to Dashboard',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getCompletionTime(int stepIndex) {
    final times = ['2:15 PM', '2:30 PM', '2:45 PM'];
    return stepIndex < times.length ? times[stepIndex] : '';
  }
}