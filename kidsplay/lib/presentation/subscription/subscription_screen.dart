import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../core/activity_recommendation_engine.dart';
import '../../theme/app_theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedPlan = 'standard';
  String _voucherCode = '';
  bool _isVoucherValid = false;
  List<Child> _children = [];
  SubscriptionPlan? _currentPlan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Mock data - in real app, this would come from Firestore
    _children = [
      Child(
        id: '1',
        name: 'Elif',
        surname: 'Yılmaz',
        birthDate: DateTime(2020, 5, 15),
        gender: 'female',
        hobbies: ['drawing', 'music'],
        hasScreenDependency: false,
        screenDependencyLevel: 'low',
        usesScreenDuringMeals: false,
        wantsToChange: true,
        dailyPlayTime: '1h',
        parentIds: ['1'],
        relationshipToParent: 'daughter',
        hasCameraPermission: true,
      ),
      Child(
        id: '2',
        name: 'Can',
        surname: 'Yılmaz',
        birthDate: DateTime(2022, 3, 10),
        gender: 'male',
        hobbies: ['games', 'sports'],
        hasScreenDependency: true,
        screenDependencyLevel: 'high',
        usesScreenDuringMeals: true,
        wantsToChange: true,
        dailyPlayTime: '2h',
        parentIds: ['1'],
        relationshipToParent: 'son',
        hasCameraPermission: false,
      ),
    ];

    _currentPlan = SubscriptionPlan(
      id: 'standard',
      name: 'Standard',
      price: 7.99,
      currency: 'USD',
      period: 'month',
      features: [
        'Unlimited access to all activities',
        'Development tracking and badges',
        'Multi-parent management',
        'Progress support',
      ],
      limitations: [
        'No camera support',
        'No live viewing',
        'No video recording',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: CustomAppBar(
        title: 'Subscription & Plans',
        automaticallyImplyLeading: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentPlanCard(theme),
            SizedBox(height: 3.h),
            _buildChildrenSection(theme),
            SizedBox(height: 3.h),
            _buildPlanComparison(theme),
            SizedBox(height: 3.h),
            _buildVoucherSection(theme),
            SizedBox(height: 3.h),
            _buildPricingBreakdown(theme),
            SizedBox(height: 3.h),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(ThemeData theme) {
    if (_currentPlan == null) return const SizedBox.shrink();

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
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
              Icon(
                Icons.star,
                color:
                    isDark ? AppTheme.onSurfaceDark : AppTheme.onSurfaceLight,
                size: 24.sp,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Current Plan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.onSurfaceDark
                        : AppTheme.onSurfaceLight,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            _currentPlan!.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.onSurfaceDark : AppTheme.onSurfaceLight,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            '\$${_currentPlan!.price.toStringAsFixed(2)}/${_currentPlan!.period}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildItem(ThemeData theme, Child child) {
    final isDark = theme.brightness == Brightness.dark;
    int age = DateTime.now().year - child.birthDate.year;
    if (DateTime.now().month < child.birthDate.month ||
        (DateTime.now().month == child.birthDate.month &&
            DateTime.now().day < child.birthDate.day)) {
      age--;
    }
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 6.w,
            backgroundColor:
                isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            child: Text(
              child.name[0],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${child.name} ${child.surname}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.onSurfaceDark
                        : AppTheme.onSurfaceLight,
                  ),
                ),
                Text(
                  '$age years old',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${_currentPlan?.price.toStringAsFixed(2) ?? '0.00'}/mo',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Children (${_children.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ..._children.map((child) => _buildChildItem(theme, child)),
        ],
      ),
    );
  }

  Widget _buildDiscountInfo(ThemeData theme) {
    double discount = 0.0;
    String discountText = '';

    if (_children.length == 2) {
      discount = 0.15;
      discountText = '15% off for the 2nd child';
    } else if (_children.length >= 3) {
      discount = 0.25;
      discountText = '25% off for 3+ children';
    }

    if (discount > 0) {
      return Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.discount,
              color: const Color(0xFF4CAF50),
              size: 20.sp,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                discountText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPlanComparison(ThemeData theme) {
    final plans = [
      SubscriptionPlan(
        id: 'free',
        name: 'Free',
        price: 0.0,
        currency: 'USD',
        period: 'month',
        features: [
          '1 activity per day',
          'Basic features',
        ],
        limitations: [
          'No camera support',
          'No development tracking',
          'No progress charts',
          'No parent scoring',
          'No sharing with other parent',
        ],
      ),
      SubscriptionPlan(
        id: 'standard',
        name: 'Standard',
        price: 7.99,
        currency: 'USD',
        period: 'month',
        features: [
          'Unlimited access to all activities',
          'Development tracking and badges',
          'Multi-parent management',
          'Progress support',
        ],
        limitations: [
          'No camera support',
          'No live viewing',
          'No video recording',
        ],
      ),
      SubscriptionPlan(
        id: 'premium',
        name: 'Premium',
        price: 12.99,
        currency: 'USD',
        period: 'month',
        features: [
          'All Standard features',
          'Camera-enabled activities',
          'Video recording (15 days storage)',
          'Parent video download',
          'Live viewing',
        ],
        limitations: [],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Comparison',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: 2.h),
        ...plans.map((plan) => _buildPlanCard(theme, plan)),
      ],
    );
  }

  Widget _buildPlanCard(ThemeData theme, SubscriptionPlan plan) {
    bool isSelected = _selectedPlan == plan.id;
    bool isCurrent = _currentPlan?.id == plan.id;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFFE0E0E0),
          width: isSelected ? 2 : 1,
        ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    Text(
                      '\$${plan.price.toStringAsFixed(2)}/${plan.period}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Current',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                )
              else if (!isSelected)
                Radio<String>(
                  value: plan.id,
                  groupValue: _selectedPlan,
                  onChanged: (value) {
                    setState(() {
                      _selectedPlan = value!;
                    });
                  },
                  activeColor: const Color(0xFF6C63FF),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Features:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: 1.h),
          ...plan.features.map((feature) => Padding(
                padding: EdgeInsets.only(bottom: 0.5.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF4CAF50),
                      size: 16.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        feature,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          if (plan.limitations.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Text(
              'Limitations:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD67B7B),
              ),
            ),
            SizedBox(height: 1.h),
            ...plan.limitations.map((limitation) => Padding(
                  padding: EdgeInsets.only(bottom: 0.5.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cancel,
                        color: const Color(0xFFD67B7B),
                        size: 16.sp,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          limitation,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildVoucherSection(ThemeData theme) {
    return Container(
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
          Text(
            'Promo Code',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _isVoucherValid
                        ? Icon(
                            Icons.check_circle,
                            color: const Color(0xFF4CAF50),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _voucherCode = value;
                      _isVoucherValid = value.isNotEmpty;
                    });
                  },
                ),
              ),
              SizedBox(width: 2.w),
              ElevatedButton(
                onPressed: _validateVoucher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Apply',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (_isVoucherValid) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF4CAF50),
                    size: 16.sp,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Promo code applied!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4CAF50),
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

  Widget _buildPricingBreakdown(ThemeData theme) {
    double basePrice = _currentPlan?.price ?? 0.0;
    double totalPrice = basePrice * _children.length;
    double discount = 0.0;

    if (_children.length == 2) {
      discount = totalPrice * 0.15;
    } else if (_children.length >= 3) {
      discount = totalPrice * 0.25;
    }

    double finalPrice = totalPrice - discount;

    return Container(
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
          Text(
            'Price Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: 2.h),
          _buildPricingRow(
              theme, 'Base Price', '\$${basePrice.toStringAsFixed(2)}'),
          _buildPricingRow(theme, 'Number of Children', '${_children.length}'),
          _buildPricingRow(
              theme, 'Subtotal', '\$${totalPrice.toStringAsFixed(2)}'),
          if (discount > 0)
            _buildPricingRow(
                theme, 'Discount', '-\$${discount.toStringAsFixed(2)}',
                isDiscount: true),
          Divider(height: 2.h),
          _buildPricingRow(theme, 'Total', '\$${finalPrice.toStringAsFixed(2)}',
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPricingRow(ThemeData theme, String label, String value,
      {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: const Color(0xFF333333),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isDiscount
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF6C63FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _upgradePlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: EdgeInsets.symmetric(vertical: 3.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Upgrade Plan',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _cancelSubscription,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD67B7B)),
              padding: EdgeInsets.symmetric(vertical: 3.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel Subscription',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD67B7B),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _validateVoucher() {
    // Voucher validation logic
    if (_voucherCode.isNotEmpty) {
      setState(() {
        _isVoucherValid = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code applied!',
              style: Theme.of(context).textTheme.bodyMedium),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }

  void _upgradePlan() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade Plan',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to upgrade your plan?',
            style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              // Upgrade logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            child: Text('Upgrade',
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _cancelSubscription() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Subscription',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to cancel your subscription?',
            style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              // Cancel subscription logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD67B7B),
            ),
            child: Text('Cancel',
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String period;
  final List<String> features;
  final List<String> limitations;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.period,
    required this.features,
    required this.limitations,
  });
}
