/// Landing Page Navigation Bar
library;

import 'package:flutter/material.dart';

class LandingNavBar extends StatelessWidget implements PreferredSizeWidget {
  const LandingNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.construction,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Toolspace',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Navigation Links (Desktop)
          if (!isMobile) ...[
            Semantics(
              label: 'nav-features',
              button: true,
              child: _NavLink(
                key: const Key('nav-features'),
                label: 'Features',
                onTap: () => Navigator.pushNamed(context, '/features'),
              ),
            ),
            const SizedBox(width: 32),
            Semantics(
              label: 'nav-pricing',
              button: true,
              child: _NavLink(
                key: const Key('nav-pricing'),
                label: 'Pricing',
                onTap: () => Navigator.pushNamed(context, '/pricing'),
              ),
            ),
            const SizedBox(width: 32),
            Semantics(
              label: 'nav-dashboard',
              button: true,
              child: _NavLink(
                key: const Key('nav-dashboard'),
                label: 'Dashboard',
                onTap: () => Navigator.pushNamed(context, '/dashboard'),
              ),
            ),
            const SizedBox(width: 24),
          ],

          // Auth Buttons
          if (!isMobile) ...[
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/auth/signin'),
              child: const Text('Sign In'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/auth/signup'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Get Started'),
            ),
          ] else
            // Mobile Menu Button
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _showMobileMenu(context);
              },
            ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Features'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Pricing'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dashboard');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign In'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/auth/signin');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Get Started'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/auth/signup');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            widget.label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: _isHovered ? FontWeight.bold : FontWeight.normal,
              color: _isHovered ? Colors.blue : null,
            ),
          ),
        ),
      ),
    );
  }
}
