import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';


class CountryPicker extends StatefulWidget {
  const CountryPicker({
    super.key,
    required this.currentCountry,
    required this.onSelected,
  });

  final String currentCountry;
  final ValueChanged<String> onSelected;

  @override
  State<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  final _searchCtrl = TextEditingController();
  late List<_Country> _filtered;

  static const _countries = [
    _Country('🇳🇬', 'Nigeria'),
    _Country('🇸🇦', 'Saudi Arabia'),
    _Country('🇪🇬', 'Egypt'),
    _Country('🇵🇰', 'Pakistan'),
    _Country('🇮🇩', 'Indonesia'),
    _Country('🇧🇩', 'Bangladesh'),
    _Country('🇹🇷', 'Turkey'),
    _Country('🇮🇷', 'Iran'),
    _Country('🇲🇾', 'Malaysia'),
    _Country('🇦🇱', 'Albania'),
    _Country('🇩🇿', 'Algeria'),
    _Country('🇦🇿', 'Azerbaijan'),
    _Country('🇧🇭', 'Bahrain'),
    _Country('🇧🇫', 'Burkina Faso'),
    _Country('🇹🇩', 'Chad'),
    _Country('🇨🇲', 'Cameroon'),
    _Country('🇩🇯', 'Djibouti'),
    _Country('🇬🇲', 'Gambia'),
    _Country('🇬🇳', 'Guinea'),
    _Country('🇮🇶', 'Iraq'),
    _Country('🇯🇴', 'Jordan'),
    _Country('🇰🇿', 'Kazakhstan'),
    _Country('🇰🇼', 'Kuwait'),
    _Country('🇰🇬', 'Kyrgyzstan'),
    _Country('🇱🇧', 'Lebanon'),
    _Country('🇱🇾', 'Libya'),
    _Country('🇲🇱', 'Mali'),
    _Country('🇲🇷', 'Mauritania'),
    _Country('🇲🇦', 'Morocco'),
    _Country('🇳🇪', 'Niger'),
    _Country('🇴🇲', 'Oman'),
    _Country('🇶🇦', 'Qatar'),
    _Country('🇸🇳', 'Senegal'),
    _Country('🇸🇱', 'Sierra Leone'),
    _Country('🇸🇴', 'Somalia'),
    _Country('🇸🇩', 'Sudan'),
    _Country('🇸🇾', 'Syria'),
    _Country('🇹🇯', 'Tajikistan'),
    _Country('🇹🇳', 'Tunisia'),
    _Country('🇹🇲', 'Turkmenistan'),
    _Country('🇦🇪', 'UAE'),
    _Country('🇺🇿', 'Uzbekistan'),
    _Country('🇾🇪', 'Yemen'),
    _Country('🇬🇧', 'United Kingdom'),
    _Country('🇺🇸', 'United States'),
    _Country('🇨🇦', 'Canada'),
    _Country('🇫🇷', 'France'),
    _Country('🇩🇪', 'Germany'),
    _Country('🇿🇦', 'South Africa'),
    _Country('🇬🇭', 'Ghana'),
    _Country('🇯🇵', 'Japan'),
    _Country('🇹🇬', 'Togo'),
  ];

  @override
  void initState() {
    super.initState();
    _filtered = _countries;
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _countries
          .where((c) => c.name.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Select Country',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search country...',
                hintStyle: const TextStyle(
                  fontFamily: 'Tajawal',
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.darkPanel,
                contentPadding:
                const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.darkBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.darkBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppColors.gold),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // List
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final country = _filtered[i];
                final isSelected =
                    country.name == widget.currentCountry;
                return ListTile(
                  onTap: () {
                    widget.onSelected(country.name);
                    Navigator.pop(context);
                  },
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    country.name,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.gold
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                    Icons.check_rounded,
                    color: AppColors.gold,
                    size: 18,
                  )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Country {
  const _Country(this.flag, this.name);
  final String flag;
  final String name;
}