import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iptv_provider.dart';
import '../config/constants.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search channels...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Consumer<IPTVProvider>(
            builder: (context, iptvProvider, child) {
              if (iptvProvider.searchQuery.isNotEmpty) {
                return IconButton(
                  onPressed: () {
                    _searchController.clear();
                    iptvProvider.clearSearch();
                  },
                  icon: const Icon(Icons.clear),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: (value) {
          Provider.of<IPTVProvider>(context, listen: false).searchChannels(value);
        },
      ),
    );
  }
}