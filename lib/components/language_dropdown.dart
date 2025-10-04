import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
      value: context.locale,
      dropdownColor: Colors.white,
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(12),
      menuWidth: 125,
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          context.setLocale(newLocale);
        }
      },

      // 👇 This controls how the selected item looks (the trigger button)
      selectedItemBuilder: (BuildContext context) {
        return [
          Image.asset("lib/assets/icons/uk.png", width: 28, height: 28),
          Image.asset("lib/assets/icons/kh.png", width: 28, height: 28),
        ];
      },

      // 👇 This is the dropdown menu content
      items: [
        DropdownMenuItem(
          value: const Locale('en'),
          child: Row(
            children: [
              Image.asset("lib/assets/icons/uk.png", width: 24, height: 24),
              const SizedBox(width: 8),
              const Text("English"),
            ],
          ),
        ),
        DropdownMenuItem(
          value: const Locale('km'),
          child: Row(
            children: [
              Image.asset("lib/assets/icons/kh.png", width: 24, height: 24),
              const SizedBox(width: 8),
              const Text("ភាសាខ្មែរ"),
            ],
          ),
        ),
      ],
    );
  }
}
