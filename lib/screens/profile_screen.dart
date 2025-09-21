import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../services/authorization_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(
      const LoadUserProfile('1'),
    ); // Assuming user ID is '1' for demo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is UserProfileLoaded ||
              state is UserProfileUpdated) {
            final user = state is UserProfileLoaded
                ? state.user
                : (state as UserProfileUpdated).user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),
                  _buildMenuItems(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                ],
              ),
            );
          }
          return const Center(child: Text('No user data'));
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: _isEditing
          ? _buildEditProfileForm(user)
          : _buildProfileDisplay(user),
    );
  }

  Widget _buildProfileDisplay(dynamic user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(user.email, style: TextStyle(color: Colors.grey[600])),
        if (user.phone != null) ...[
          const SizedBox(height: 4),
          Text(user.phone!, style: TextStyle(color: Colors.grey[600])),
        ],
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: user.isAdmin ? Colors.blue[100] : Colors.green[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            user.role.displayName,
            style: TextStyle(
              color: user.isAdmin ? Colors.blue[800] : Colors.green[800],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileForm(dynamic user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone ?? '');

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Name is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Email is required';
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
              return 'Invalid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: phoneController,
          decoration: const InputDecoration(labelText: 'Phone (optional)'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                if (_validateForm(nameController.text, emailController.text)) {
                  context.read<UserBloc>().add(
                    UpdateUserProfile(
                      userId: user.id,
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text.isEmpty
                          ? null
                          : phoneController.text,
                    ),
                  );
                  setState(() {
                    _isEditing = false;
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  bool _validateForm(String name, String email) {
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required')));
      return false;
    }
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Valid email is required')));
      return false;
    }
    return true;
  }

  Widget _buildMenuItems() {
    final user = (context.read<UserBloc>().state is UserProfileLoaded)
        ? (context.read<UserBloc>().state as UserProfileLoaded).user
        : (context.read<UserBloc>().state is UserProfileUpdated)
        ? (context.read<UserBloc>().state as UserProfileUpdated).user
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('My Orders'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to orders screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Addresses'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to addresses screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payment Methods'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to payment methods screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to notifications screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to help screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to about screen
            },
          ),
          // Admin menu items
          if (user != null &&
              AuthorizationService.canAccessAdminFeatures(user)) ...[
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.blue,
              ),
              title: const Text('Admin Dashboard'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to admin dashboard
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.blue),
              title: const Text('Manage Products'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to product management
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.blue),
              title: const Text('Manage Orders'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to order management
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue),
              title: const Text('Manage Users'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to user management
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          context.read<AuthBloc>().add(LogoutRequested());
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Colors.red),
        ),
        child: const Text('Logout', style: TextStyle(color: Colors.red)),
      ),
    );
  }
}
