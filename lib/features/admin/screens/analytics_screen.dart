import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/widgets/custom_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with TickerProviderStateMixin {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'This Quarter', 'This Year'];
  String _selectedCategory = 'All';
  String _selectedRegion = 'All';
  String _chartType = 'Collections';
  late AnimationController _chartAnimationController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeInOutCubic,
    );
    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    super.dispose();
  }

  void _restartAnimation() {
    _chartAnimationController.reset();
    _chartAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb && width > 900;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isWeb ? 32 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWeb) _buildWebHeader(theme),
                if (isWeb) _buildWebFilterBar(theme),
                if (!isWeb) _buildMobileHeader(theme),
                SizedBox(height: isWeb ? 32 : 24),
                _buildKeyMetrics(theme, isWeb),
                SizedBox(height: isWeb ? 32 : 24),
                _buildMonthlyTrendChart(theme, isWeb),
                SizedBox(height: isWeb ? 32 : 24),
                _buildCategoryStatistics(theme, isWeb),
                SizedBox(height: isWeb ? 32 : 24),
                _buildRegionalHeatmap(theme, isWeb),
                SizedBox(height: isWeb ? 32 : 24),
                _buildPerformanceMetrics(theme, isWeb),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Analytics',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: _restartAnimation,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Analytics',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => setState(() => _selectedPeriod = value),
          itemBuilder: (context) => _periods.map((period) {
            return PopupMenuItem(value: period, child: Text(period));
          }).toList(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _selectedPeriod,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebFilterBar(ThemeData theme) {
    return Row(
      children: [
        ..._periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedPeriod = period);
                  _restartAnimation();
                }
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildKeyMetrics(ThemeData theme, bool isWeb) {
    return GridView.count(
      crossAxisCount: isWeb ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isWeb ? 1.3 : 1.24,
      children: [
        _buildMetricCard(theme, 'Total Collections', '1,234', '+12%', Icons.delete_outline, const Color(0xFF0F5132), true, isWeb),
        _buildMetricCard(theme, 'Revenue', '\$45,678', '+8%', Icons.attach_money, const Color(0xFF0F5132), true, isWeb),
        _buildMetricCard(theme, 'Satisfaction', '4.8/5', '+0.2', Icons.star, const Color(0xFF0F5132), true, isWeb),
        _buildMetricCard(theme, 'Response Time', '2.3 hrs', '-15%', Icons.access_time, const Color(0xFF0F5132), false, isWeb),
      ],
    );
  }

  Widget _buildMetricCard(
    ThemeData theme,
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
    bool isPositive,
    bool isWeb,
  ) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(isWeb ? 5 : 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(icon, color: color, size: isWeb ? 14 : 12),
                ),
                Icon(Icons.trending_up, color: isPositive ? Colors.green : Colors.red, size: 9),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isWeb ? 20 : 15,
                    color: theme.colorScheme.onSurface,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isWeb ? 10 : 9,
                    color: theme.colorScheme.onSurface,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  change,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: isWeb ? 8 : 7,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrendChart(ThemeData theme, bool isWeb) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Trend',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isWeb)
                DropdownButton<String>(
                  value: _chartType,
                  underline: const SizedBox(),
                  items: ['Collections', 'Revenue', 'Complaints'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _chartType = value!);
                    _restartAnimation();
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: isWeb ? 300 : 200,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return LineChart(
                  LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Jan');
                          case 1:
                            return const Text('Feb');
                          case 2:
                            return const Text('Mar');
                          case 3:
                            return const Text('Apr');
                          case 4:
                            return const Text('May');
                          case 5:
                            return const Text('Jun');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, 100 * _chartAnimation.value),
                      FlSpot(1, 120 * _chartAnimation.value),
                      FlSpot(2, 110 * _chartAnimation.value),
                      FlSpot(3, 140 * _chartAnimation.value),
                      FlSpot(4, 160 * _chartAnimation.value),
                      FlSpot(5, 180 * _chartAnimation.value),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: const Color(0xFF0F5132),
                    barWidth: isWeb ? 4 : 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF0F5132),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0F5132).withOpacity(0.3),
                          const Color(0xFF0F5132).withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStatistics(ThemeData theme, bool isWeb) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Statistics',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isWeb ? 20 : 16,
            ),
          ),
          const SizedBox(height: 16),
          isWeb ? Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 200,
                  child: AnimatedBuilder(
                    animation: _chartAnimation,
                    builder: (context, child) {
                      return PieChart(
                        PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: 35 * _chartAnimation.value,
                          color: const Color(0xFF0F5132),
                          title: '35%',
                          radius: 70 * _chartAnimation.value,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: 25 * _chartAnimation.value,
                          color: const Color(0xFF2D7A4F),
                          title: '25%',
                          radius: 70 * _chartAnimation.value,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: 20 * _chartAnimation.value,
                          color: const Color(0xFF5A9F6E),
                          title: '20%',
                          radius: 70 * _chartAnimation.value,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: 20 * _chartAnimation.value,
                          color: const Color(0xFF87C48D),
                          title: '20%',
                          radius: 70 * _chartAnimation.value,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryLegend('Household', '432', Colors.blue),
                    const SizedBox(height: 8),
                    _buildCategoryLegend('Recyclables', '308', Colors.green),
                    const SizedBox(height: 8),
                    _buildCategoryLegend('Garden', '246', Colors.orange),
                    const SizedBox(height: 8),
                    _buildCategoryLegend('Others', '248', Colors.red),
                  ],
                ),
              ),
            ],
          ) : Column(
            children: [
              SizedBox(
                height: 160,
                child: AnimatedBuilder(
                  animation: _chartAnimation,
                  builder: (context, child) {
                    return PieChart(
                      PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 35 * _chartAnimation.value,
                        color: const Color(0xFF0F5132),
                        title: '35%',
                        radius: 50 * _chartAnimation.value,
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: 25 * _chartAnimation.value,
                        color: const Color(0xFF2D7A4F),
                        title: '25%',
                        radius: 50 * _chartAnimation.value,
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: 20 * _chartAnimation.value,
                        color: const Color(0xFF5A9F6E),
                        title: '20%',
                        radius: 50 * _chartAnimation.value,
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: 20 * _chartAnimation.value,
                        color: const Color(0xFF87C48D),
                        title: '20%',
                        radius: 50 * _chartAnimation.value,
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                  ),
                );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _buildCategoryLegend('Household', '432', const Color(0xFF0F5132)),
                  _buildCategoryLegend('Recyclables', '308', const Color(0xFF2D7A4F)),
                  _buildCategoryLegend('Garden', '246', const Color(0xFF5A9F6E)),
                  _buildCategoryLegend('Others', '248', const Color(0xFF87C48D)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLegend(String category, String count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          category,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 2),
        Text(
          '($count)',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRegionalHeatmap(ThemeData theme, bool isWeb) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Regional Heatmap',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            height: isWeb ? 250 : 200,
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
                    'Regional Heatmap',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Interactive map showing pickup density by area',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Regional Stats
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              _buildRegionalStat(theme, 'Downtown', '45%', const Color(0xFF0F5132)),
              _buildRegionalStat(theme, 'Suburbs', '30%', const Color(0xFF2D7A4F)),
              _buildRegionalStat(theme, 'Industrial', '15%', const Color(0xFF5A9F6E)),
              _buildRegionalStat(theme, 'Rural', '10%', const Color(0xFF87C48D)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegionalStat(ThemeData theme, String area, String percentage, Color color) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                percentage,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            area,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(ThemeData theme, bool isWeb) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Column(
            children: [
              _buildPerformanceItem(
                theme,
                'Average Response Time',
                '2.3 hours',
                0.8,
                const Color(0xFF0F5132),
              ),
              const SizedBox(height: 16),
              _buildPerformanceItem(
                theme,
                'Customer Satisfaction',
                '4.8/5.0',
                0.96,
                const Color(0xFF2D7A4F),
              ),
              const SizedBox(height: 16),
              _buildPerformanceItem(
                theme,
                'Driver Efficiency',
                '92%',
                0.92,
                const Color(0xFF5A9F6E),
              ),
              const SizedBox(height: 16),
              _buildPerformanceItem(
                theme,
                'Complaint Resolution',
                '95%',
                0.95,
                const Color(0xFF87C48D),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(
    ThemeData theme,
    String title,
    String value,
    double progress,
    Color color,
  ) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb && width > 900;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isWeb ? 13 : 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: isWeb ? 13 : 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _chartAnimation,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress * _chartAnimation.value,
                minHeight: isWeb ? 8 : 6,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            );
          },
        ),
      ],
    );
  }
}