import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_app_bar.dart';

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
        relationship: 'Mother',
        profileImageUrl: 'https://example.com/ayse.jpg',
        isPrimary: true,
        permissions: ['view', 'edit', 'invite', 'delete'],
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Parent(
        id: '2',
        name: 'Mehmet Yılmaz',
        email: 'mehmet@example.com',
        relationship: 'Father',
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
        email: 'grandma@example.com',
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: CustomAppBar(
        title: 'Multi-Parent Management',
        automaticallyImplyLeading: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildParentsTab(theme),
                _buildSharedChildrenTab(theme),
                _buildInvitationsTab(theme),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        labelStyle:
            theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: theme.textTheme.titleMedium,
        tabs: const [
          Tab(text: 'Parents'),
          Tab(text: 'Shared Children'),
          Tab(text: 'Invitations'),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    if (_tabController.index == 0) {
      return FloatingActionButton.extended(
        onPressed: _showInviteParentDialog,
        backgroundColor: theme.colorScheme.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(
          'Invite Parent',
          style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildParentsTab(ThemeData theme) {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _parents.length,
      itemBuilder: (context, index) {
        return _buildParentCard(theme, _parents[index]);
      },
    );
  }

  Widget _buildParentCard(ThemeData theme, Parent parent) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
              CircleAvatar(
                radius: 8.w,
                backgroundImage: parent.profileImageUrl.isNotEmpty
                    ? NetworkImage(parent.profileImageUrl)
                    : null,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: parent.profileImageUrl.isEmpty
                    ? Text(
                        parent.name[0],
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (parent.isPrimary) ...[
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Primary',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      parent.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      parent.relationship,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (!parent.isPrimary)
                PopupMenuButton<String>(
                  onSelected: (value) => _handleParentAction(value, parent),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFF6C63FF)),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'permissions',
                      child: Row(
                        children: [
                          Icon(Icons.security, color: Color(0xFF6C63FF)),
                          SizedBox(width: 8),
                          Text('Permissions'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove, color: Color(0xFFD67B7B)),
                          SizedBox(width: 8),
                          Text('Remove'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    size: 20.sp,
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Permissions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: parent.permissions.map((permission) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPermissionText(permission),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 1.h),
          Text(
            'Joined: ${_formatDate(parent.joinedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedChildrenTab(ThemeData theme) {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _sharedChildren.length,
      itemBuilder: (context, index) {
        return _buildSharedChildCard(theme, _sharedChildren[index]);
      },
    );
  }

  Widget _buildSharedChildCard(ThemeData theme, SharedChild sharedChild) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
              CircleAvatar(
                radius: 8.w,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(
                  sharedChild.childName[0],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${sharedChild.childAge} years old',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      'Shared by ${sharedChild.parentIds.length} parents',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleSharedChildAction(value, sharedChild),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view_progress',
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: Color(0xFF6C63FF)),
                        SizedBox(width: 8),
                        Text('View Progress'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'manage_permissions',
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Color(0xFF6C63FF)),
                        SizedBox(width: 8),
                        Text('Manage Permissions'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'remove_sharing',
                    child: Row(
                      children: [
                        Icon(Icons.share, color: Color(0xFFD67B7B)),
                        SizedBox(width: 8),
                        Text('Remove Sharing'),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Sharing Permissions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: sharedChild.permissions.map((permission) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPermissionText(permission),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 1.h),
          Text(
            'Shared: ${_formatDate(sharedChild.sharedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsTab(ThemeData theme) {
    if (_pendingInvitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.email_outlined,
              size: 64.sp,
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
            SizedBox(height: 2.h),
            Text(
              'No pending invitations',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Use the "Invite Parent" button to send a new invitation',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
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
        return _buildInvitationCard(theme, _pendingInvitations[index]);
      },
    );
  }

  Widget _buildInvitationCard(ThemeData theme, Invitation invitation) {
    final daysLeft = invitation.expiresAt.difference(DateTime.now()).inDays;
    final isExpired = daysLeft < 0;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
              CircleAvatar(
                radius: 8.w,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.email,
                  color: theme.colorScheme.primary,
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Invited by: ${invitation.invitedBy}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      'Child: ${invitation.childName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (isExpired)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD67B7B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Expired',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD67B7B),
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$daysLeft days left',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Permissions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: invitation.permissions.map((permission) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPermissionText(permission),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
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
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Resend',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
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
                      backgroundColor: const Color(0xFFD67B7B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: theme.textTheme.bodyMedium?.copyWith(
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
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invite Parent',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Email address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Relationship (e.g. Mother, Father, Guardian)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text('Permissions', style: theme.textTheme.titleSmall),
            SizedBox(height: 1.h),
            // permission checkboxes can be added here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              // Send invitation logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
            ),
            child: Text('Send Invitation',
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
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
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Parent',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove ${parent.name}?',
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
              // Remove parent logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD67B7B),
            ),
            child: Text('Remove',
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRemoveSharingDialog(SharedChild sharedChild) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Sharing',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to remove sharing for ${sharedChild.childName}?',
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
              // Remove sharing logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD67B7B),
            ),
            child: Text('Remove',
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _resendInvitation(Invitation invitation) {
    // Resend invitation logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation resent',
            style: Theme.of(context).textTheme.bodyMedium),
        backgroundColor: const Color(0xFF4CAF50),
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
        content: Text('Invitation cancelled',
            style: Theme.of(context).textTheme.bodyMedium),
        backgroundColor: const Color(0xFFD67B7B),
      ),
    );
  }

  String _getPermissionText(String permission) {
    switch (permission) {
      case 'view':
        return 'View';
      case 'edit':
        return 'Edit';
      case 'invite':
        return 'Invite';
      case 'delete':
        return 'Delete';
      case 'progress':
        return 'Progress';
      default:
        return permission;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
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
