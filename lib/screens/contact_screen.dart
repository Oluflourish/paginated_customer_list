import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:cognisto_test/models/contact_model.dart';
import 'package:cognisto_test/models/pagination_response.dart';
import 'package:cognisto_test/service/api_service.dart';
import 'package:cognisto_test/widgets/customer_widget.dart';
import 'package:cognisto_test/widgets/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  static const _pageSize = 10;

  final PagingController<int, ContactModel> _pagingController =
      PagingController(firstPageKey: 0);

  final TextEditingController _searchQueryController = TextEditingController();
  final searchText = ValueNotifier<String>('');

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) => _fetchPage(pageKey));
    _searchQueryController.addListener(_debounceSearch);
    super.initState();
  }

  void _debounceSearch() {
    // Debounce the search input to prevent excessive API calls
    Future.delayed(const Duration(milliseconds: 300), () {
      searchText.value = _searchQueryController.text;
      _pagingController.refresh();
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithSearchSwitch(
        customTextEditingController: _searchQueryController,
        clearOnClose: true,
        onChanged: (text) {
          searchText.value = text;
        },
        elevation: 16,
        appBarBuilder: (context) {
          return AppBar(
            title: Text(
              'Customer List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            centerTitle: false,
            actions: const [AppBarSearchButton()],
          );
        },
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: RefreshIndicator(
          onRefresh: () async {
            _pagingController.refresh();
            _searchQueryController.clear();
            searchText.value = '';
          },
          child: PagedListView<int, ContactModel>(
            pagingController: _pagingController,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            builderDelegate: PagedChildBuilderDelegate<ContactModel>(
              firstPageProgressIndicatorBuilder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: SkeletonLoaderWidget(items: 8),
              ),
              newPageProgressIndicatorBuilder: (context) =>
                  SkeletonLoaderWidget(items: 2),
              firstPageErrorIndicatorBuilder: (context) => _buildErrorPage(),
              newPageErrorIndicatorBuilder: (context) => _buildNewPageError(),
              noItemsFoundIndicatorBuilder: (context) => _buildNoItemFound(),
              itemBuilder: (context, contact, index) =>
                  CustomerWidget(contact: contact),
            ),
          ),
        ),
      ),
    );
  }

  _buildNoItemFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 54, color: Colors.black26),
          const Gap(16),
          Text(
            searchText.value.isNotEmpty
                ? 'No customers found for "${searchText.value}"'
                : 'No customers found',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  _buildNewPageError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 54, color: Colors.red),
          const Gap(16),
          Text(
            'Error loading more customers',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
          const Gap(8),
          ElevatedButton(
            onPressed: () {
              _pagingController.retryLastFailedRequest();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  _buildErrorPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 54, color: Colors.red),
          const Gap(16),
          Text(
            'Error loading customers',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
          const Gap(8),
          ElevatedButton(
            onPressed: () {
              _pagingController.refresh();
              _searchQueryController.clear();
              searchText.value = '';
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      PaginationResponse<List<ContactModel>> paginationResponse;

      List<ContactModel> newItems;

      if (searchText.value.isNotEmpty) {
        // If there is a search query, clear the current list and refresh
        _pagingController.itemList?.clear();
        _pagingController.refresh();

        // If there is a search query, fetch search results
        paginationResponse = await ApiService.searchContacts(
          pageKey: pageKey,
          pageSize: _pageSize,
          query: searchText.value,
        );
        newItems = paginationResponse.items;

        final isLastPage = newItems.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + newItems.length;
          _pagingController.appendPage(newItems, nextPageKey);
        }

        return;
      }

      paginationResponse = await ApiService.fetchContacts(
        pageKey: pageKey,
        pageSize: _pageSize,
      );
      newItems = paginationResponse.items;

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }
}
