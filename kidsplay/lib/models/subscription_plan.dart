class SubscriptionPlan {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String period;
  final List<String> features;
  final List<String> limitations;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.period,
    required this.features,
    required this.limitations,
  });

  static const plans = <SubscriptionPlan>[
    SubscriptionPlan(
      id: 'free',
      name: 'Free',
      price: 0.0,
      currency: 'USD',
      period: 'month',
      features: ['1 activity per day', 'Basic features'],
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
      limitations: ['No camera support', 'No live viewing', 'No video recording'],
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

  static SubscriptionPlan byId(String id) =>
      plans.firstWhere((p) => p.id == id, orElse: () => plans.first);
}