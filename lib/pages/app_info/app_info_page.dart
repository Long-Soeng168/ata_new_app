import 'package:ata_new_app/pages/app_info/web_view_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_SectionItem> sections = [
      _SectionItem(
        title: 'About Us',
        icon: Icons.info_outline,
        color: Colors.blue,
        onTap: () {
          final route = MaterialPageRoute(
              builder: (context) => WebViewPage(
                    title: 'About Us',
                    url: 'https://atech-auto.com/about-us-webview',
                  ));
          Navigator.push(context, route);
        },
      ),
      _SectionItem(
        title: 'Contact Us',
        icon: Icons.phone_outlined,
        color: Colors.green,
        onTap: () {
          final route = MaterialPageRoute(
              builder: (context) => WebViewPage(
                    title: 'Contact Us',
                    url:
                        'https://atech-auto.com/contact-us-webview',
                  ));
          Navigator.push(context, route);
        },
      ),
      _SectionItem(
        title: 'Privacy Policy',
        icon: Icons.privacy_tip_outlined,
        color: Colors.deepPurple,
        onTap: () {
          final route = MaterialPageRoute(
              builder: (context) => WebViewPage(
                    title: 'Privacy Policy',
                    url: 'https://atech-auto.com/privacy-webview',
                  ));
          Navigator.push(context, route);
        },
      ),
      _SectionItem(
        title: 'Our Website',
        icon: Icons.public_outlined,
        color: Colors.orange,
        onTap: () async {
          final url = Uri.parse('https://atech-auto.com');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            // Handle error if URL can't be launched
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch $url')),
            );
          }
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Info'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: section.color.withOpacity(0.1),
                child: Icon(section.icon, color: section.color),
              ),
              title: Text(
                section.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: section.onTap,
            ),
          );
        },
      ),
    );
  }
}

class _SectionItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _SectionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
