import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      backgroundColor: const Color(0xFFF8F9FA),
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF6C63FF),
        unselectedLabelColor: const Color(0xFF999999),
        indicatorColor: const Color(0xFF6C63FF),
        indicatorWeight: 3,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
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
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(
          'Ebeveyn Davet Et',
          style: GoogleFonts.poppins(
            color: Colors.white,
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
              CircleAvatar(
                radius: 8.w,
                backgroundImage: NetworkImage(parent.profileImageUrl),
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                child: parent.profileImageUrl.isEmpty
                    ? Text(
                        parent.name[0],
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6C63FF),
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
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        if (parent.isPrimary) ...[
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Birincil',
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      parent.email,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    Text(
                      parent.relationship,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: const Color(0xFF999999),
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
                          Text('Düzenle'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'permissions',
                      child: Row(
                        children: [
                          Icon(Icons.security, color: Color(0xFF6C63FF)),
                          SizedBox(width: 8),
                          Text('İzinler'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove, color: Color(0xFFD67B7B)),
                          SizedBox(width: 8),
                          Text('Kaldır'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: const Color(0xFF666666),
                    size: 20.sp,
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'İzinler',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
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
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPermissionText(permission),
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 1.h),
          Text(
            'Katılım: ${_formatDate(parent.joinedAt)}',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: const Color(0xFF999999),
            ),
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
              CircleAvatar(
                radius: 8.w,
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                child: Text(
                  sharedChild.childName[0],
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C63FF),
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
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    Text(
                      '${sharedChild.childAge} yaşında',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    Text(
                      '${sharedChild.parentIds.length} ebeveyn paylaşıyor',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleSharedChildAction(value, sharedChild),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view_progress',
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: Color(0xFF6C63FF)),
                        SizedBox(width: 8),
                        Text('İlerlemeyi Görüntüle'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'manage_permissions',
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Color(0xFF6C63FF)),
                        SizedBox(width: 8),
                        Text('İzinleri Yönet'),
                      ],
                    ),
                  ),
                                       PopupMenuItem(
                       value: 'remove_sharing',
                       child: Row(
                         children: [
                           Icon(Icons.share, color: const Color(0xFFD67B7B)),
                           const SizedBox(width: 8),
                           const Text('Paylaşımı Kaldır'),
                         ],
                       ),
                     ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: const Color(0xFF666666),
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Paylaşım İzinleri',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
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
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPermissionText(permission),
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 1.h),
          Text(
            'Paylaşım: ${_formatDate(sharedChild.sharedAt)}',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: const Color(0xFF999999),
            ),
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
              color: const Color(0xFFCCCCCC),
            ),
            SizedBox(height: 2.h),
            Text(
              'Bekleyen davet yok',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF999999),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Yeni ebeveyn davet etmek için\n"Ebeveyn Davet Et" butonunu kullanın',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: const Color(0xFF999999),
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
        return _buildInvitationCard(_pendingInvitations[index]);
      },
    );
  }

  Widget _buildInvitationCard(Invitation invitation) {
    final daysLeft = invitation.expiresAt.difference(DateTime.now()).inDays;
    final isExpired = daysLeft < 0;

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
              CircleAvatar(
                radius: 8.w,
                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                child: Icon(
                  Icons.email,
                  color: const Color(0xFF6C63FF),
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
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    Text(
                      'Davet eden: ${invitation.invitedBy}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    Text(
                      'Çocuk: ${invitation.childName}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              if (isExpired)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD67B7B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Süresi Doldu',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD67B7B),
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$daysLeft gün kaldı',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'İzinler',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
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
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPermissionText(permission),
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6C63FF),
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
                      side: const BorderSide(color: Color(0xFF6C63FF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Yeniden Gönder',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6C63FF),
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
                      'İptal Et',
                      style: GoogleFonts.poppins(
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
              style: GoogleFonts.poppins(color: const Color(0xFF666666)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Send invitation logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            child: Text(
              'Davet Gönder',
              style: GoogleFonts.poppins(color: Colors.white),
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${parent.name} adlı ebeveyni kaldırmak istediğinizden emin misiniz?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: const Color(0xFF666666)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Remove parent logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD67B7B),
            ),
            child: Text(
              'Kaldır',
              style: GoogleFonts.poppins(color: Colors.white),
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${sharedChild.childName} için paylaşımı kaldırmak istediğinizden emin misiniz?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: const Color(0xFF666666)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Remove sharing logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD67B7B),
            ),
            child: Text(
              'Kaldır',
              style: GoogleFonts.poppins(color: Colors.white),
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
          style: GoogleFonts.poppins(),
        ),
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
        content: Text(
          'Davet iptal edildi',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFFD67B7B),
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
