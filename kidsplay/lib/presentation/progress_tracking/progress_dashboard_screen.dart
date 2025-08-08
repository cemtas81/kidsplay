import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/activity_recommendation_engine.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class ProgressDashboardScreen extends StatefulWidget {
  final Child child;

  const ProgressDashboardScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ProgressDashboardScreen> createState() => _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';
  List<ActivityLog> _activityLogs = [];
  List<Achievement> _achievements = [];
  int _currentTabIndex = 0;
  final List<String> _periods = ['Week', 'Month', 'Quarter', 'Year'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProgressData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadProgressData() {
    // Mock data - in real app, this would come from Firestore
    _activityLogs = [
      ActivityLog(
        id: '1',
        activityId: 'activity1',
        activityName: 'Resim Yapma',
        childId: widget.child.id,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        duration: 30,
        parentRating: 4,
        childHappiness: 5,
        attentionSpan: 25,
        resultImageUrl: 'https://example.com/result1.jpg',
        completionDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ActivityLog(
        id: '2',
        activityId: 'activity2',
        activityName: 'Dans Etme',
        childId: widget.child.id,
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        duration: 45,
        parentRating: 5,
        childHappiness: 5,
        attentionSpan: 40,
        resultImageUrl: null,
        completionDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ActivityLog(
        id: '3',
        activityId: 'activity3',
        activityName: 'Puzzle',
        childId: widget.child.id,
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        duration: 20,
        parentRating: 3,
        childHappiness: 4,
        attentionSpan: 18,
        resultImageUrl: null,
        completionDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    _achievements = [
      Achievement(
        id: '1',
        name: 'İlk Aktivite',
        description: 'İlk aktiviteyi tamamladın!',
        icon: '🎉',
        unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
        type: 'milestone',
      ),
      Achievement(
        id: '2',
        name: 'Sanat Ustası',
        description: '5 resim aktivitesi tamamladın',
        icon: '🎨',
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
        type: 'skill',
      ),
      Achievement(
        id: '3',
        name: 'Dikkatli Çocuk',
        description: '30 dakika boyunca odaklandın',
        icon: '🎯',
        unlockedAt: DateTime.now().subtract(const Duration(days: 1)),
        type: 'focus',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: CustomAppBar(
        title: '${widget.child.name}\'s Progress',
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () {
              // Share progress
            },
            icon: CustomIconWidget(
              iconName: 'share',
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              size: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabNavigation(context),
          Expanded(
            child: _buildTabContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton(context, 'Overview', 0),
          SizedBox(width: 2.w),
          _buildTabButton(context, 'Activities', 1),
          SizedBox(width: 2.w),
          _buildTabButton(context, 'Achievements', 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String title, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _currentTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTabIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isSelected
                  ? (isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight)
                  : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (_currentTabIndex) {
      case 0:
        return _buildOverviewTab(context);
      case 1:
        return _buildActivitiesTab();
      case 2:
        return _buildAchievementsTab();
      default:
        return _buildOverviewTab(context);
    }
  }

  Widget _buildOverviewTab(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(context),
          SizedBox(height: 3.h),
          _buildSummaryCards(context),
          SizedBox(height: 3.h),
          _buildWeeklyChart(context),
          SizedBox(height: 3.h),
          _buildSkillProgress(context),
          SizedBox(height: 3.h),
          _buildRecentActivities(context),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Text(
              'Period:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                isExpanded: true,
                underline: Container(),
                items: _periods.map((String period) {
                  return DropdownMenuItem<String>(
                    value: period,
                    child: Text(
                      period,
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPeriod = newValue;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            title: 'Activities',
            value: '24',
            subtitle: 'Completed',
            icon: 'check_circle',
            color: isDark ? AppTheme.successDark : AppTheme.successLight,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: 'Time',
            value: '12.5h',
            subtitle: 'Total',
            icon: 'schedule',
            color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: 'Points',
            value: '1,250',
            subtitle: 'Earned',
            icon: 'stars',
            color: isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required String icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 20,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Activity',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              height: 20.h,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Color(0xff67727d),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          Widget text;
                          switch (value.toInt()) {
                            case 0:
                              text = const Text('Mon', style: style);
                              break;
                            case 1:
                              text = const Text('Tue', style: style);
                              break;
                            case 2:
                              text = const Text('Wed', style: style);
                              break;
                            case 3:
                              text = const Text('Thu', style: style);
                              break;
                            case 4:
                              text = const Text('Fri', style: style);
                              break;
                            case 5:
                              text = const Text('Sat', style: style);
                              break;
                            case 6:
                              text = const Text('Sun', style: style);
                              break;
                            default:
                              text = const Text('', style: style);
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: text,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Color(0xff67727d),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          return Text(value.toInt().toString(), style: style);
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                    ),
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(1, 2),
                        const FlSpot(2, 5),
                        const FlSpot(3, 3.1),
                        const FlSpot(4, 4),
                        const FlSpot(5, 3),
                        const FlSpot(6, 4),
                      ],
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                          isDark ? AppTheme.primaryVariantDark : AppTheme.primaryVariantLight,
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                            strokeWidth: 2,
                            strokeColor: isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            (isDark ? AppTheme.primaryDark : AppTheme.primaryLight).withValues(alpha: 0.3),
                            (isDark ? AppTheme.primaryDark : AppTheme.primaryLight).withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillProgress(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skill Progress',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildSkillItem(context, 'Creativity', 0.8, 'brush'),
            SizedBox(height: 1.h),
            _buildSkillItem(context, 'Physical Activity', 0.6, 'directions_run'),
            SizedBox(height: 1.h),
            _buildSkillItem(context, 'Problem Solving', 0.9, 'psychology'),
            SizedBox(height: 1.h),
            _buildSkillItem(context, 'Social Skills', 0.7, 'people'),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillItem(BuildContext context, String skill, double progress, String icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
            size: 16,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    skill,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                ),
                minHeight: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activities',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ..._activityLogs.map((log) => _buildActivityLogItem(context, log)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLogItem(BuildContext context, ActivityLog log) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: _getActivityIcon(log.activityType),
              color: isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.activityName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${log.duration} minutes • ${log.completionDate.toString().substring(0, 10)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.successDark : AppTheme.successLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${log.pointsEarned} pts',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _activityLogs.length,
      itemBuilder: (context, index) {
        return _buildDetailedActivityItem(_activityLogs[index]);
      },
    );
  }

  Widget _buildDetailedActivityItem(ActivityLog log) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  log.activityName,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tamamlandı',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              _buildMetricItem('Süre', '${log.duration} dk', Icons.timer),
              SizedBox(width: 4.w),
              _buildMetricItem('Puan', '${log.parentRating}/5', Icons.star),
              SizedBox(width: 4.w),
              _buildMetricItem('Mutluluk', '${log.childHappiness}/5', Icons.favorite),
            ],
          ),
          SizedBox(height: 2.h),
          if (log.resultImageUrl != null)
            Container(
              height: 15.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(log.resultImageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16.sp, color: const Color(0xFF6C63FF)),
            SizedBox(height: 0.5.h),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 3.w,
        childAspectRatio: 0.8,
      ),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(_achievements[index]);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.icon,
            style: TextStyle(fontSize: 32.sp),
          ),
          SizedBox(height: 1.h),
          Text(
            achievement.name,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            achievement.description,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: const Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatDate(achievement.unlockedAt),
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'Resim Yapma':
        return 'brush';
      case 'Dans Etme':
        return 'directions_run';
      case 'Puzzle':
        return 'psychology';
      default:
        return 'check_circle';
    }
  }
}

class ActivityLog {
  final String id;
  final String activityId;
  final String activityName;
  final String childId;
  final DateTime completedAt;
  final int duration;
  final int parentRating;
  final int childHappiness;
  final int attentionSpan;
  final String? resultImageUrl;
  final String activityType; // Added for new icon mapping
  final DateTime completionDate; // Added for new date format
  final int pointsEarned; // Added for new points display

  ActivityLog({
    required this.id,
    required this.activityId,
    required this.activityName,
    required this.childId,
    required this.completedAt,
    required this.duration,
    required this.parentRating,
    required this.childHappiness,
    required this.attentionSpan,
    this.resultImageUrl,
    this.activityType = 'Other',
    required this.completionDate,
    this.pointsEarned = 0,
  });
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime unlockedAt;
  final String type; // milestone, skill, focus, etc.

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    required this.type,
  });
}

