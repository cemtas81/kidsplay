import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/panels.dart';
import '../../core/app_export.dart';

class MultiParentScreen extends StatefulWidget {
  const MultiParentScreen({Key? key}) : super(key: key);

  @override
  State<MultiParentScreen> createState() => _MultiParentScreenState();
}

class _MultiParentScreenState extends State<MultiParentScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Parent> _parents = [];
  List<SharedChild> _sharedChildren = [];
  List<Invitation> _pendingInvitations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    // Mock data - in real app, this would come from Firestore
    _parents = [
      Parent(
        id: '1',
        name: 'Ayşe Yılmaz',
        email: 'ayse@example.com',
        relationship: 'Anne',
        profileImageUrl: 'https://example.com/ayse.jpg',
        isPrimary: true,
        permissions: ['view', 'edit', 'invite', 'delete'],
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Parent(
        id: '2',
        name: 'Mehmet Yılmaz',
        email: 'mehmet@example.com',
        relationship: 'Baba',
        profileImageUrl: 'https://example.com/mehmet.jpg',
        isPrimary: false,
        permissions: ['view', 'edit'],
        joinedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    _sharedChildren = [
      SharedChild(
        id: '1',
        childId: 'child1',
        childName: 'Elif Yılmaz',
        childAge: 4,
        parentIds: ['1', '2'],
        sharedAt: DateTime.now().subtract(const Duration(days: 20)),
        permissions: ['view', 'edit', 'progress'],
      ),
      SharedChild(
        id: '2',
        childId: 'child2',
        childName: 'Can Yılmaz',
        childAge: 2,
        parentIds: ['1', '2'],
        sharedAt: DateTime.now().subtract(const Duration(days: 10)),
        permissions: ['view', 'edit', 'progress'],
      ),
    ];

    _pendingInvitations = [
      Invitation(
        id: '1',
        email: 'anneanne@example.com',
        invitedBy: 'Ayşe Yılmaz',
        childName: 'Elif Yılmaz',
        permissions: ['view', 'progress'],
        sentAt: DateTime.now().subtract(const Duration(days: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Çoklu Ebeveyn Yönetimi',
        automaticallyImplyLeading: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildParentsTab(),
                _buildSharedChildrenTab(),
                _buildInvitationsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildTabBar() {
    return PanelCard(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        unselectedLabelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
        tabs: const [
          Tab(text: 'Ebeveynler'),
          Tab(text: 'Paylaşılan Çocuklar'),
          Tab(text: 'Davetler'),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_tabController.index == 0) {
      return FloatingActionButton.extended(
        onPressed: _showInviteParentDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: Icon(Icons.person_add, color: Theme.of(context).colorScheme.onPrimary),
        label: Text(
          'Ebeveyn Davet Et',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildParentsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _parents.length,
      itemBuilder: (context, index) {
        return _buildParentCard(_parents[index]);
      },
    );
  }

  Widget _buildParentCard(Parent parent) {
    return PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 8.w,
                backgroundImage: NetworkImage(parent.profileImageUrl),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: parent.profileImageUrl.isEmpty
                    ? Text(
                        parent.name[0],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      )
                    : null,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          parent.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (parent.isPrimary) ...[
                          SizedBox(width: 2.w),
                          StatusChip(
                            label: 'Birincil',
                            color: AppTheme.success,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      parent.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      parent.relationship,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (!parent.isPrimary)
                PopupMenuButton<String>(
                  onSelected: (value) => _handleParentAction(value, parent),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text('Düzenle'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'permissions',
                      child: Row(
                        children: [
                          Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text('İzinler'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove, color: AppTheme.error),
                          const SizedBox(width: 8),
                          const Text('Kaldır'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20.sp,
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'İzinler',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: parent.permissions.map((permission) {
              return StatusChip(
                label: _getPermissionText(permission),
                color: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
          SizedBox(height: 1.h),
          Text(
            'Katılım: ${_formatDate(parent.joinedAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSharedChildrenTab() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _sharedChildren.length,
      itemBuilder: (context, index) {
        return _buildSharedChildCard(_sharedChildren[index]);
      },
    );
  }

  Widget _buildSharedChildCard(SharedChild sharedChild) {
    return PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 8.w,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Text(
                  sharedChild.childName[0],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sharedChild.childName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${sharedChild.childAge} yaşında',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${sharedChild.parentIds.length} ebeveyn paylaşıyor',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleSharedChildAction(value, sharedChild),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view_progress',
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('İlerlemeyi Görüntüle'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'manage_permissions',
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('İzinleri Yönet'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove_sharing',
                    child: Row(
                      children: [
                        Icon(Icons.share, color: AppTheme.error),
                        const SizedBox(width: 8),
                        const Text('Paylaşımı Kaldır'),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Paylaşım İzinleri',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: sharedChild.permissions.map((permission) {
              return StatusChip(
                label: _getPermissionText(permission),
                color: AppTheme.success,
              );
            }).toList(),
          ),
          SizedBox(height: 1.h),
          Text(
            'Paylaşım: ${_formatDate(sharedChild.sharedAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsTab() {
    if (_pendingInvitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.email_outlined,
              size: 64.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 2.h),
            Text(
              'Bekleyen davet yok',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Yeni ebeveyn davet etmek için\n"Ebeveyn Davet Et" butonunu kullanın',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _pendingInvitations.length,
      itemBuilder: (context, index) {
        return _buildInvitationCard(_pendingInvitations[index]);
      },
    );
  }

  Widget _buildInvitationCard(Invitation invitation) {
    final daysLeft = invitation.expiresAt.difference(DateTime.now()).inDays;
    final isExpired = daysLeft < 0;

    return PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 8.w,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.email,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invitation.email,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Davet eden: ${invitation.invitedBy}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Çocuk: ${invitation.childName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isExpired)
                StatusChip(
                  label: 'Süresi Doldu',
                  color: AppTheme.error,
                )
              else
                StatusChip(
                  label: '$daysLeft gün kaldı',
                  color: AppTheme.warning,
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'İzinler',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: invitation.permissions.map((permission) {
              return StatusChip(
                label: _getPermissionText(permission),
                color: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
          SizedBox(height: 2.h),
          if (!isExpired)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _resendInvitation(invitation),
                    child: Text(
                      'Yeniden Gönder',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _cancelInvitation(invitation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'İptal Et',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showInviteParentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Ebeveyn Davet Et',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'E-posta Adresi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'İlişki (Anne, Baba, Veli vb.)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'İzinler',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            // Add permission checkboxes here
          ],
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
              // Send invitation logic
              Navigator.pop(context);
            },
            child: Text(
              'Davet Gönder',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleParentAction(String action, Parent parent) {
    switch (action) {
      case 'edit':
        // Show edit parent dialog
        break;
      case 'permissions':
        // Show permissions dialog
        break;
      case 'remove':
        _showRemoveParentDialog(parent);
        break;
    }
  }

  void _handleSharedChildAction(String action, SharedChild sharedChild) {
    switch (action) {
      case 'view_progress':
        // Navigate to progress screen
        break;
      case 'manage_permissions':
        // Show permissions dialog
        break;
      case 'remove_sharing':
        _showRemoveSharingDialog(sharedChild);
        break;
    }
  }

  void _showRemoveParentDialog(Parent parent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Ebeveyni Kaldır',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Text(
          '${parent.name} adlı ebeveyni kaldırmak istediğinizden emin misiniz?',
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
              // Remove parent logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Kaldır',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveSharingDialog(SharedChild sharedChild) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Paylaşımı Kaldır',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Text(
          '${sharedChild.childName} için paylaşımı kaldırmak istediğinizden emin misiniz?',
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
              // Remove sharing logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Kaldır',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _resendInvitation(Invitation invitation) {
    // Resend invitation logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Davet yeniden gönderildi',
          style: Theme.of(context).snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _cancelInvitation(Invitation invitation) {
    // Cancel invitation logic
    setState(() {
      _pendingInvitations.remove(invitation);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Davet iptal edildi',
          style: Theme.of(context).snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  String _getPermissionText(String permission) {
    switch (permission) {
      case 'view':
        return 'Görüntüleme';
      case 'edit':
        return 'Düzenleme';
      case 'invite':
        return 'Davet Etme';
      case 'delete':
        return 'Silme';
      case 'progress':
        return 'İlerleme';
      default:
        return permission;
    }
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
}

class Parent {
  final String id;
  final String name;
  final String email;
  final String relationship;
  final String profileImageUrl;
  final bool isPrimary;
  final List<String> permissions;
  final DateTime joinedAt;

  Parent({
    required this.id,
    required this.name,
    required this.email,
    required this.relationship,
    required this.profileImageUrl,
    required this.isPrimary,
    required this.permissions,
    required this.joinedAt,
  });
}

class SharedChild {
  final String id;
  final String childId;
  final String childName;
  final int childAge;
  final List<String> parentIds;
  final DateTime sharedAt;
  final List<String> permissions;

  SharedChild({
    required this.id,
    required this.childId,
    required this.childName,
    required this.childAge,
    required this.parentIds,
    required this.sharedAt,
    required this.permissions,
  });
}

class Invitation {
  final String id;
  final String email;
  final String invitedBy;
  final String childName;
  final List<String> permissions;
  final DateTime sentAt;
  final DateTime expiresAt;

  Invitation({
    required this.id,
    required this.email,
    required this.invitedBy,
    required this.childName,
    required this.permissions,
    required this.sentAt,
    required this.expiresAt,
  });
}
