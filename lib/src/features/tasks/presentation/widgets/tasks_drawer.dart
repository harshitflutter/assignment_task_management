import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/constants/app_strings.dart';
import 'package:task_management/src/core/constants/app_text_styles.dart';
import 'package:task_management/src/core/routes/app_routes.dart';
import 'package:task_management/src/features/tasks/presentation/cubit/user_profile_cubit.dart';

class TasksDrawer extends StatelessWidget {
  const TasksDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // User Profile Header
          BlocBuilder<UserProfileCubit, UserProfileState>(
            builder: (context, state) {
              if (state is UserProfileLoaded) {
                return UserAccountsDrawerHeader(
                  accountName: Text(
                    state.user.displayName ?? AppStrings.user,
                    style: AppTextStyles.drawerHeaderTextStyle,
                  ),
                  accountEmail: Text(
                    state.user.email ?? AppStrings.noEmail,
                    style: AppTextStyles.drawerSubtitleTextStyle,
                  ),
                  currentAccountPicture: CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: state.user.photoURL != null
                        ? NetworkImage(state.user.photoURL!)
                        : null,
                    child: state.user.photoURL == null
                        ? Text(
                            _getInitials(state.user.displayName),
                            style: AppTextStyles.headerTextStyle.copyWith(
                              fontSize: 24.sp,
                              color: AppColors.white,
                            ),
                          )
                        : null,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                );
              } else if (state is UserProfileLoading) {
                return const UserAccountsDrawerHeader(
                  accountName: Text(AppStrings.loading),
                  accountEmail: Text(AppStrings.pleaseWait),
                  currentAccountPicture: CircularProgressIndicator(),
                );
              } else {
                return const UserAccountsDrawerHeader(
                  accountName: Text(AppStrings.user),
                  accountEmail: Text(AppStrings.noUserData),
                  currentAccountPicture: Icon(Icons.person),
                );
              }
            },
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text(AppStrings.editProfile),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditProfileDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text(AppStrings.userInfo),
                  onTap: () {
                    Navigator.pop(context);
                    _showUserInfoDialog(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    AppStrings.logout,
                    style: TextStyle(color: AppColors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final userProfileCubit = context.read<UserProfileCubit>();
    final currentState = userProfileCubit.state;

    if (currentState is! UserProfileLoaded) return;

    final user = currentState.user;
    final nameController = TextEditingController(text: user.displayName ?? '');
    final emailController = TextEditingController(text: user.email ?? '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 20,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.drawerGradient1,
                AppColors.drawerGradient2,
                AppColors.drawerGradient3,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: user.photoURL == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppStrings.editProfile,
                        style: AppTextStyles.dialogTitleTextStyle,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppStrings.updateYourPersonalInformation,
                        style: AppTextStyles.dialogSubtitleTextStyle,
                      ),
                    ],
                  ),
                ),
                // Form Content
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.r),
                      bottomRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.fieldShadow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: AppStrings.displayName,
                            hintText: AppStrings.enterYourDisplayName,
                            prefixIcon: const Icon(Icons.person_outline,
                                color: AppColors.drawerGradient1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                  color: AppColors.drawerGradient1, width: 2),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.fieldShadow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: AppStrings.email,
                            hintText: AppStrings.yourEmailAddress,
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: AppColors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            enabled: false,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.grey.withOpacity(0.1),
                                    AppColors.grey.withOpacity(0.2),
                                  ],
                                ),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  AppStrings.cancel,
                                  style: AppTextStyles.buttonTextStyleSecondary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Container(
                              height: 50.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.drawerGradient1,
                                    AppColors.drawerGradient2
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.drawerGradient1
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextButton(
                                onPressed: () {
                                  if (nameController.text.trim().isNotEmpty) {
                                    userProfileCubit.updateProfile(
                                      displayName: nameController.text.trim(),
                                    );
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(AppStrings
                                            .profileUpdatedSuccessfully),
                                        backgroundColor: AppColors.green,
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  AppStrings.saveChanges,
                                  style: AppTextStyles.buttonTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserInfoDialog(BuildContext context) {
    final userProfileCubit = context.read<UserProfileCubit>();
    final currentState = userProfileCubit.state;

    if (currentState is! UserProfileLoaded) return;

    final user = currentState.user;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 20,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.drawerGradient3,
                AppColors.drawerGradient4,
                AppColors.drawerGradient5,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.white.withOpacity(0.2),
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.white,
                            )
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'User Information',
                      style: AppTextStyles.dialogTitleTextStyle,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Your account details',
                      style: AppTextStyles.dialogSubtitleTextStyle,
                    ),
                  ],
                ),
              ),
              // Content
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.r),
                    bottomRight: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  children: [
                    _buildModernInfoCard(
                      icon: Icons.email_outlined,
                      title: 'Email Address',
                      value: user.email ?? 'Not provided',
                      color: AppColors.drawerGradient5,
                    ),
                    SizedBox(height: 12.h),
                    _buildModernInfoCard(
                      icon: Icons.person_outline,
                      title: 'Display Name',
                      value: user.displayName ?? 'Not set',
                      color: AppColors.drawerGradient4,
                    ),
                    SizedBox(height: 12.h),
                    _buildModernInfoCard(
                      icon: user.emailVerified
                          ? Icons.verified
                          : Icons.warning_outlined,
                      title: 'Email Status',
                      value: user.emailVerified ? 'Verified' : 'Not Verified',
                      color: user.emailVerified
                          ? AppColors.green
                          : AppColors.orange,
                    ),
                    SizedBox(height: 12.h),
                    _buildModernInfoCard(
                      icon: Icons.calendar_today,
                      title: 'Member Since',
                      value: _formatDate(user.metadata.creationTime),
                      color: AppColors.drawerGradient3,
                    ),
                    SizedBox(height: 12.h),
                    _buildModernInfoCard(
                      icon: Icons.access_time,
                      title: 'Last Sign In',
                      value: _formatDate(user.metadata.lastSignInTime),
                      color: AppColors.drawerGradient1,
                    ),
                    SizedBox(height: 24.h),
                    Container(
                      width: double.infinity,
                      height: 50.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.drawerGradient3,
                            AppColors.drawerGradient4
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.drawerGradient3.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Close',
                          style: AppTextStyles.buttonTextStyle.copyWith(
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: AppColors.cardBackground,
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.infoCardTitleTextStyle,
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: AppTextStyles.infoCardValueTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.signIn);
              await context.read<UserProfileCubit>().logout();

              // Navigate to sign-in screen after logout
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return 'U';
    }

    final words = displayName.trim().split(' ');
    if (words.isEmpty) {
      return 'U';
    }

    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }

    // Get first letter of first and last word
    final firstInitial = words[0].substring(0, 1).toUpperCase();
    final lastInitial = words[words.length - 1].substring(0, 1).toUpperCase();
    return '$firstInitial$lastInitial';
  }
}
