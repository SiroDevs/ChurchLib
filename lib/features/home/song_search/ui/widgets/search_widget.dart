part of '../song_search_screen.dart';

class SearchWidget extends StatelessWidget {
  final Function(String) onSearch;
  final FocusNode? searchFocus;
  final TextEditingController? searchController;
  const SearchWidget({
    super.key,
    required this.onSearch,
    required this.searchFocus,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: searchFocus,
      controller: searchController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: 'Search a song by title or words',
        isDense: true,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          tooltip: 'Clear',
          icon: const Icon(Icons.clear),
          onPressed: () {
            searchController!.clear();
            onSearch('');
          },
        ),
      ),
      style: const TextStyle(fontSize: 16),
      textInputAction: TextInputAction.done,
      onChanged: (String query) => onSearch(query),
    );
  }
}
