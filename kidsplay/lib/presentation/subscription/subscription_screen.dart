import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/custom_app_bar.dart';
import '../../core/activity_recommendation_engine.dart';
import '../../core/app_export.dart';
import '../../widgets/panels.dart';

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
        hobbies: ['resim', 'müzik'],
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
        hobbies: ['oyun', 'spor'],
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
      name: 'Standart',
      price: 7.99,
      currency: 'USD',
      period: 'month',
      features: [
        'Tüm aktivitelere sınırsız erişim',
        'Gelişim takibi ve rozetler',
        'Çoklu ebeveyn yönetimi',
        'İlerleme desteği',
      ],
      limitations: [
        'Kamera desteği yok',
        'Canlı izleme yok',
        'Video kaydı yok',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
        title: 'Üyelik ve Planlar',
        automaticallyImplyLeading: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentPlanCard(),
            SizedBox(height: 3.h),
            _buildChildrenSection(),
            SizedBox(height: 3.h),
            _buildPlanComparison(),
            SizedBox(height: 3.h),
            _buildVoucherSection(),
            SizedBox(height: 3.h),
            _buildPricingBreakdown(),
            SizedBox(height: 3.h),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    if (_currentPlan == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                color: Theme.of(context).colorScheme.onPrimary,
                size: 24.sp,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Mevcut Plan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            _currentPlan!.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            '\$${_currentPlan!.price.toStringAsFixed(2)}/${_currentPlan!.period}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Özellikler:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          SizedBox(height: 1.h),
          ..._currentPlan!.features.map((feature) => Padding(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    feature,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                        ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildChildrenSection() {
    return PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Çocuklar (${_children.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 2.h),
          ..._children.map((child) => _buildChildItem(child)),
          SizedBox(height: 2.h),
          _buildDiscountInfo(),
        ],
      ),
    );
  }

  Widget _buildChildItem(Child child) {
    int age = DateTime.now().year - child.birthDate.year;
    if (DateTime.now().month < child.birthDate.month || 
        (DateTime.now().month == child.birthDate.month && DateTime.now().day < child.birthDate.day)) {
      age--;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              child.name[0],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '$age yaşında',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            '\$${_currentPlan?.price.toStringAsFixed(2) ?? '0.00'}/ay',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountInfo() {
    double discount = 0.0;
    String discountText = '';

    if (_children.length == 2) {
      discount = 0.15;
      discountText = '2. çocuk için %15 indirim';
    } else if (_children.length >= 3) {
      discount = 0.25;
      discountText = '3+ çocuk için %25 indirim';
    }

    if (discount > 0) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: (isDark ? AppTheme.successDark : AppTheme.successLight).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (isDark ? AppTheme.successDark : AppTheme.successLight).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.discount,
              color: isDark ? AppTheme.successDark : AppTheme.successLight,
              size: 20.sp,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                discountText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.successDark : AppTheme.successLight,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPlanComparison() {
    final plans = [
      SubscriptionPlan(
        id: 'free',
        name: 'Ücretsiz',
        price: 0.0,
        currency: 'USD',
        period: 'month',
        features: [
          'Günde 1 aktivite',
          'Temel özellikler',
        ],
        limitations: [
          'Kamera desteği yok',
          'Gelişim takibi yok',
          'İlerleme grafikleri yok',
          'Ebeveyn puanlaması yok',
          'Diğer ebeveynle paylaşım yok',
        ],
      ),
      SubscriptionPlan(
        id: 'standard',
        name: 'Standart',
        price: 7.99,
        currency: 'USD',
        period: 'month',
        features: [
          'Tüm aktivitelere sınırsız erişim',
          'Gelişim takibi ve rozetler',
          'Çoklu ebeveyn yönetimi',
          'İlerleme desteği',
        ],
        limitations: [
          'Kamera desteği yok',
          'Canlı izleme yok',
          'Video kaydı yok',
        ],
      ),
      SubscriptionPlan(
        id: 'premium',
        name: 'Premium',
        price: 12.99,
        currency: 'USD',
        period: 'month',
        features: [
          'Tüm Standart özellikler',
          'Kamera destekli aktiviteler',
          'Video kaydı (15 gün saklama)',
          'Ebeveyn video indirme',
          'Canlı izleme',
        ],
        limitations: [],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Karşılaştırması',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        ...plans.map((plan) => _buildPlanCard(plan)),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    bool isSelected = _selectedPlan == plan.id;
    bool isCurrent = _currentPlan?.id == plan.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: PanelCard(
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '\$${plan.price.toStringAsFixed(2)}/${plan.period}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  StatusChip(
                    label: 'Mevcut',
                    color: isDark ? AppTheme.successDark : AppTheme.successLight,
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
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'Özellikler:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            ...plan.features.map((feature) => Padding(
              padding: EdgeInsets.only(bottom: 0.5.h),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: isDark ? AppTheme.successDark : AppTheme.successLight,
                    size: 16.sp,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
            if (plan.limitations.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Text(
                'Sınırlamalar:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.errorDark : AppTheme.errorLight,
                    ),
              ),
              SizedBox(height: 1.h),
              ...plan.limitations.map((limitation) => Padding(
                padding: EdgeInsets.only(bottom: 0.5.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.cancel,
                      color: isDark ? AppTheme.errorDark : AppTheme.errorLight,
                      size: 16.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        limitation,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Promosyon Kodu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Promosyon kodunuzu girin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _isVoucherValid
                        ? Icon(
                            Icons.check_circle,
                            color: isDark ? AppTheme.successDark : AppTheme.successLight,
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Uygula',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
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
                color: (isDark ? AppTheme.successDark : AppTheme.successLight).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: isDark ? AppTheme.successDark : AppTheme.successLight,
                    size: 16.sp,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Promosyon kodu geçerli!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.successDark : AppTheme.successLight,
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

  Widget _buildPricingBreakdown() {
    double basePrice = _currentPlan?.price ?? 0.0;
    double totalPrice = basePrice * _children.length;
    double discount = 0.0;

    if (_children.length == 2) {
      discount = totalPrice * 0.15;
    } else if (_children.length >= 3) {
      discount = totalPrice * 0.25;
    }

    double finalPrice = totalPrice - discount;

    return PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fiyat Detayı',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 2.h),
          _buildPricingRow('Temel Fiyat', '\$${basePrice.toStringAsFixed(2)}'),
          _buildPricingRow('Çocuk Sayısı', '${_children.length}'),
          _buildPricingRow('Ara Toplam', '\$${totalPrice.toStringAsFixed(2)}'),
          if (discount > 0)
            _buildPricingRow('İndirim', '-\$${discount.toStringAsFixed(2)}', isDiscount: true),
          Divider(height: 2.h),
          _buildPricingRow('Toplam', '\$${finalPrice.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal 
              ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
              : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: isTotal 
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                )
              : Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDiscount 
                    ? (isDark ? AppTheme.successDark : AppTheme.successLight)
                    : Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _upgradePlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: EdgeInsets.symmetric(vertical: 3.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Planı Yükselt',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
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
              side: BorderSide(color: isDark ? AppTheme.errorDark : AppTheme.errorLight),
              padding: EdgeInsets.symmetric(vertical: 3.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Üyeliği İptal Et',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.errorDark : AppTheme.errorLight,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  void _validateVoucher() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Voucher validation logic
    if (_voucherCode.isNotEmpty) {
      setState(() {
        _isVoucherValid = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Promosyon kodu uygulandı!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          backgroundColor: isDark ? AppTheme.successDark : AppTheme.successLight,
        ),
      );
    }
  }

  void _upgradePlan() {
    // Plan upgrade logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Plan Yükseltme',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Planınızı yükseltmek istediğinizden emin misiniz?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Upgrade logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Yükselt',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelSubscription() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Üyelik İptali',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Üyeliğinizi iptal etmek istediğinizden emin misiniz?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Cancel subscription logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.errorDark : AppTheme.errorLight,
            ),
            child: Text(
              'İptal Et',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
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
