import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/auth_service.dart';
import '../../repositories/parent_repository.dart';
import '../../repositories/child_repository.dart';
import '../../repositories/invitation_repository.dart';
import '../../models/parent.dart';
import '../../models/child.dart';
import '../../models/invitation.dart';

class MultiParentScreen extends StatefulWidget {
  const MultiParentScreen({Key? key}) : super(key: key);

  @override
  State<MultiParentScreen> createState() => _MultiParentScreenState();
}

class _MultiParentScreenState extends State<MultiParentScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _parentRepo = ParentRepository();
  final _childRepo = ChildRepository();
  final _invRepo = InvitationRepository();

  String? _uid;
  String? _invitedByName; // could be fetched from user profile
  List<Child> _children = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController
        .addListener(() => setState(() {})); // update FAB on tab switch
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final user = await AuthService.ensureInitializedAndSignedIn();
    setState(() {
      _uid = user.uid;
      _invitedByName = 'You'; // replace with profile name if available
    });
    // prefetch children for invite dialog convenience
    _childRepo.watchChildrenOf(user.uid).listen((chs) {
      setState(() {
        _children = chs;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_uid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
    return StreamBuilder(
      stream: _parentRepo.watchParents(_uid!),
      builder: (context, AsyncSnapshot<List<Parent>> snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final parents = snap.data!;
        if (parents.isEmpty) {
          return Center(
            child: Text('No parents yet', style: theme.textTheme.bodyMedium),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(4.w),
          itemCount: parents.length,
          itemBuilder: (context, index) {
            return _buildParentCard(theme, parents[index]);
          },
        );
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
                        parent.name.isNotEmpty ? parent.name[0] : '?',
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
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFF6C63FF)),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'permissions',
                      child: Row(
                        children: [
                          Icon(Icons.security, color: Color(0xFF6C63FF)),
                          SizedBox(width: 8),
                          Text('Permissions'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
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
    return StreamBuilder<List<Child>>(
      stream: _childRepo.watchChildrenOf(_uid!),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final children = snap.data!;
        final shared = children.where((c) => c.parentIds.length > 1).toList();
        if (shared.isEmpty) {
          return Center(
              child: Text('No shared children',
                  style: theme.textTheme.bodyMedium));
        }
        return ListView.builder(
          padding: EdgeInsets.all(4.w),
          itemCount: shared.length,
          itemBuilder: (context, i) => _buildSharedChildCard(theme, shared[i]),
        );
      },
    );
  }

  Widget _buildSharedChildCard(ThemeData theme, Child child) {
    final permissions = <String>[
      'view',
      'edit',
      'progress'
    ]; // demo: could be stored per parent-child
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
                  child.name.isNotEmpty ? child.name[0] : '?',
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
                      '${child.name} ${child.surname}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${_age(child.birthDate)} years old',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      'Shared by ${child.parentIds.length} parents',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleSharedChildAction(value, child),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'view_progress',
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: Color(0xFF6C63FF)),
                        SizedBox(width: 8),
                        Text('View Progress'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
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
            children: permissions.map((permission) {
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
        ],
      ),
    );
  }

  Widget _buildInvitationsTab(ThemeData theme) {
    return StreamBuilder<List<Invitation>>(
      stream: _invRepo.watchInvitations(_uid!),
      builder: (context, snap) {
        if (!snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final invitations = snap.data!;
        if (invitations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email_outlined,
                    size: 64.sp,
                    color: theme.colorScheme.onSurface.withOpacity(0.2)),
                SizedBox(height: 2.h),
                Text('No pending invitations',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.5))),
                SizedBox(height: 1.h),
                Text('Use the "Invite Parent" button to send a new invitation',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    textAlign: TextAlign.center),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(4.w),
          itemCount: invitations.length,
          itemBuilder: (context, i) =>
              _buildInvitationCard(theme, invitations[i]),
        );
      },
    );
  }

  Widget _buildInvitationCard(ThemeData theme, Invitation inv) {
    final daysLeft = inv.expiresAt.difference(DateTime.now()).inDays;
    final isExpired = daysLeft < 0 || inv.status == 'expired';
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
              offset: const Offset(0, 2)),
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
                child: Icon(Icons.email,
                    color: theme.colorScheme.primary, size: 20.sp),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inv.email,
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface)),
                    Text('Invited by: ${inv.invitedBy}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.7))),
                    Text('Child: ${inv.childName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.5))),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: isExpired
                      ? const Color(0xFFD67B7B).withOpacity(0.1)
                      : const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isExpired ? 'Expired' : '$daysLeft days left',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isExpired
                        ? const Color(0xFFD67B7B)
                        : const Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text('Permissions',
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface)),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: inv.permissions
                .map((p) => Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(_getPermissionText(p),
                          style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary)),
                    ))
                .toList(),
          ),
          SizedBox(height: 2.h),
          if (!isExpired && inv.status == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _resendInvitation(inv),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Resend',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _cancelInvitation(inv),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD67B7B),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Cancel',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600)),
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
    final emailCtrl = TextEditingController();
    final relCtrl = TextEditingController();
    String? selectedChildId = _children.isNotEmpty ? _children.first.id : null;
    final perms = <String, bool>{
      'view': true,
      'edit': true,
      'progress': true,
      'invite': false,
      'delete': false
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invite Parent',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedChildId,
                items: _children
                    .map((c) => DropdownMenuItem(
                        value: c.id, child: Text('${c.name} ${c.surname}')))
                    .toList(),
                onChanged: (v) => selectedChildId = v,
                decoration: InputDecoration(
                    labelText: 'Child',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8))),
              ),
              SizedBox(height: 1.5.h),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                    labelText: 'Email address',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8))),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 1.5.h),
              TextField(
                controller: relCtrl,
                decoration: InputDecoration(
                    labelText: 'Relationship (e.g. Mother, Father, Guardian)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8))),
              ),
              SizedBox(height: 1.5.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Permissions',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              SizedBox(height: 0.5.h),
              ...perms.keys.map((k) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: perms[k],
                    title: Text(_getPermissionText(k)),
                    onChanged: (v) => {perms[k] = v ?? false, setState(() {})},
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: theme.textTheme.bodyMedium)),
          ElevatedButton(
            onPressed: () async {
              if (selectedChildId == null || emailCtrl.text.trim().isEmpty)
                return;
              final child =
                  _children.firstWhere((c) => c.id == selectedChildId);
              await _invRepo.invite(
                uid: _uid!,
                email: emailCtrl.text.trim(),
                invitedBy: _invitedByName ?? 'You',
                childId: child.id,
                childName: '${child.name} ${child.surname}',
                permissions: perms.entries
                    .where((e) => e.value)
                    .map((e) => e.key)
                    .toList(),
              );
              if (mounted) Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invitation sent')));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary),
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
        // TODO: Implement edit parent dialog (name/relationship)
        break;
      case 'permissions':
        // TODO: Implement per-parent permission management
        break;
      case 'remove':
        _showRemoveParentDialog(parent);
        break;
    }
  }

  void _handleSharedChildAction(String action, Child child) {
    switch (action) {
      case 'view_progress':
        // TODO: Navigate to actual progress screen
        break;
      case 'manage_permissions':
        // TODO: Implement permissions for this child
        break;
      case 'remove_sharing':
        _showRemoveSharingDialog(child);
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
              child: Text('Cancel', style: theme.textTheme.bodyMedium)),
          ElevatedButton(
            onPressed: () async {
              await _parentRepo.removeParent(_uid!, parent.id);
              if (mounted) Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Parent removed')));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD67B7B)),
            child: Text('Remove',
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRemoveSharingDialog(Child child) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Sharing',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        content: Text(
            'Remove sharing for ${child.name} ${child.surname}? This will keep the child only under your account.',
            style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: theme.textTheme.bodyMedium)),
          ElevatedButton(
            onPressed: () async {
              await _childRepo.removeSharingKeepOwner(
                  ownerUid: _uid!, childId: child.id);
              if (mounted) Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing removed')));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD67B7B)),
            child: Text('Remove',
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _resendInvitation(Invitation inv) async {
    await _invRepo.resend(_uid!, inv.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Invitation resent')));
  }

  Future<void> _cancelInvitation(Invitation inv) async {
    await _invRepo.cancel(_uid!, inv.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Invitation cancelled')));
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
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  int _age(DateTime birthDate) {
    int age = DateTime.now().year - birthDate.year;
    final hasHadBirthday = (DateTime.now().month > birthDate.month) ||
        (DateTime.now().month == birthDate.month &&
            DateTime.now().day >= birthDate.day);
    if (!hasHadBirthday) age--;
    return age;
  }
}
