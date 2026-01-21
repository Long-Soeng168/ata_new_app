import 'package:flutter/material.dart';

// Replace with your ErrorImage if you have it
// import 'package:ata_new_app/components/error_image.dart';

class ShopCard extends StatelessWidget {
  const ShopCard({
    super.key,
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.logoUrl,
    this.onTap,
  });

  final int id;
  final String name;
  final String address;
  final String phone;
  final String logoUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top Branding Header
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 60, // increased header height
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primaryContainer.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: -20,
                    child: CircleAvatar(
                      radius: 35, // bigger decorative circle
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  // Logo Positioned half-way off the header
                  Positioned(
                    bottom: -35,
                    left: 16,
                    child: Container(
                      width: 80, // bigger logo
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.store, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40), // adjusted space for bigger logo

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              // fontWeight: FontWeight.bold,
                              // letterSpacing: -0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 6),
                    // _InfoRow(
                    //   icon: Icons.phone_enabled_rounded,
                    //   text: phone,
                    //   color: theme.colorScheme.primary,
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoRow({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.7)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
