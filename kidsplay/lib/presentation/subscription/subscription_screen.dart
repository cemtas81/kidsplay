import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/app_theme.dart';
import '../../models/child.dart';
import '../../models/subscription_plan.dart';
import '../../services/auth_service.dart';
import '../../repositories/child_repository.dart';
import '../../repositories/subscription_repository.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _childRepo = ChildRepository();
  final _subRepo = SubscriptionRepository();

  String _selectedPlan = 'standard';
  String _voucherCode = '';
  bool _isVoucherValid = false;

  String? _uid;
  List<Child> _children = [];
  SubscriptionPlan? _currentPlan;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final user = await AuthService.ensureInitializedAndSignedIn();
    setState(() {
      _uid = user.uid;
    });

    _childRepo.watchChildrenOf(user.uid).listen((kids) {
      setState(() => _children = kids);
    });

    _subRepo.watchCurrentPlan(user.uid).listen((plan) {
      setState(() => _currentPlan = plan ?? SubscriptionPlan.byId('free'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
              Icon(Icons.star,
                  color:
                      isDark ? AppTheme.onSurfaceDark : AppTheme.onSurfaceLight,
                  size: 24.sp),
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
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Children (${_children.length})',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 2.h),
          ..._children.map((child) => _buildChildItem(theme, child)),
        ],
      ),
    );
  }

  Widget _buildPlanComparison(ThemeData theme) {
    final plans = SubscriptionPlan.plans;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plan Comparison',
            style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600, color: const Color(0xFF333333))),
        SizedBox(height: 2.h),
        ...plans.map((plan) => _buildPlanCard(theme, plan)),
      ],
    );
  }

  Widget _buildPlanCard(ThemeData theme, SubscriptionPlan plan) {
    final isSelected = _selectedPlan == plan.id;
    final isCurrent = _currentPlan?.id == plan.id;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                isSelected ? const Color(0xFF6C63FF) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
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
                      Text(plan.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333))),
                      Text('\$${plan.price.toStringAsFixed(2)}/${plan.period}',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6C63FF))),
                    ]),
              ),
              if (isCurrent)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('Current',
                      style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4CAF50))),
                )
              else if (!isSelected)
                Radio<String>(
                  value: plan.id,
                  groupValue: _selectedPlan,
                  onChanged: (value) => setState(() => _selectedPlan = value!),
                  activeColor: const Color(0xFF6C63FF),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text('Features:',
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: const Color(0xFF333333))),
          SizedBox(height: 1.h),
          ...plan.features.map((f) => Padding(
                padding: EdgeInsets.only(bottom: 0.5.h),
                child: Row(children: [
                  Icon(Icons.check_circle,
                      color: const Color(0xFF4CAF50), size: 16.sp),
                  SizedBox(width: 2.w),
                  Expanded(
                      child: Text(f,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF666666)))),
                ]),
              )),
          if (plan.limitations.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Text('Limitations:',
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD67B7B))),
            SizedBox(height: 1.h),
            ...plan.limitations.map((l) => Padding(
                  padding: EdgeInsets.only(bottom: 0.5.h),
                  child: Row(children: [
                    Icon(Icons.cancel,
                        color: const Color(0xFFD67B7B), size: 16.sp),
                    SizedBox(width: 2.w),
                    Expanded(
                        child: Text(l,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF666666)))),
                  ]),
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
                offset: const Offset(0, 2))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Promo Code',
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: const Color(0xFF333333))),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    suffixIcon: _isVoucherValid
                        ? const Icon(Icons.check_circle,
                            color: Color(0xFF4CAF50))
                        : null,
                  ),
                  onChanged: (v) => setState(() {
                    _voucherCode = v.trim();
                    _isVoucherValid = false;
                  }),
                ),
              ),
              SizedBox(width: 2.w),
              ElevatedButton(
                onPressed: _validateVoucher,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: Text('Apply',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          if (_isVoucherValid) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: const Color(0xFF4CAF50), size: 16.sp),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text('Promo code applied!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4CAF50))),
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
    final basePrice = _currentPlan?.price ?? 0.0;
    final totalPrice = basePrice * _children.length;
    double discount = 0.0;
    if (_children.length == 2) {
      discount = totalPrice * 0.15;
    } else if (_children.length >= 3) {
      discount = totalPrice * 0.25;
    }
    final finalPrice = totalPrice - discount;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: const Color(0xFF333333))),
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
          Text(label,
              style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: isTotal ? 16.sp : 14.sp,
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                  color: const Color(0xFF333333))),
          Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: isTotal ? 16.sp : 14.sp,
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                  color: isDiscount
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF6C63FF))),
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
                    borderRadius: BorderRadius.circular(12))),
            child: Text('Upgrade Plan',
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
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
                    borderRadius: BorderRadius.circular(12))),
            child: Text('Cancel Subscription',
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD67B7B))),
          ),
        ),
      ],
    );
  }

  Future<void> _validateVoucher() async {
    if (_voucherCode.isEmpty) return;
    final ok = await _subRepo.validateVoucher(_voucherCode);
    setState(() => _isVoucherValid = ok);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Promo code applied!' : 'Invalid promo code',
          style: Theme.of(context).textTheme.bodyMedium),
      backgroundColor: ok ? const Color(0xFF4CAF50) : const Color(0xFFD67B7B),
    ));
  }

  Future<void> _upgradePlan() async {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade Plan',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        content: Text(
            'Upgrade to ${SubscriptionPlan.byId(_selectedPlan).name}?',
            style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7)))),
          ElevatedButton(
            onPressed: () async {
              await _subRepo.setPlan(_uid!, _selectedPlan,
                  voucherCode: _isVoucherValid ? _voucherCode : null);
              if (mounted) Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan updated')));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF)),
            child: Text('Upgrade',
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelSubscription() async {
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
              child: Text('Close',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7)))),
          ElevatedButton(
            onPressed: () async {
              await _subRepo.cancel(_uid!);
              if (mounted) Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subscription cancelled')));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD67B7B)),
            child: Text('Cancel',
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
