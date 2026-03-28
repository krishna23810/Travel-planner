import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_planner/model/place_model.dart';
import 'package:travel_planner/res/colors.dart';
import 'package:travel_planner/res/components/shimmer_widget.dart';
import 'package:travel_planner/utils/routes/routes_name.dart';
import 'package:travel_planner/view_modal/discovery_view_modal.dart';
import 'package:travel_planner/data/response/status.dart';
import 'package:travel_planner/utils/utils.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class DiscoverScreen extends StatefulWidget {
  final String? searchQuery;
  const DiscoverScreen({super.key, this.searchQuery});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _filterController = TextEditingController();
  Status? _lastStatus;

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<DiscoveryViewModel>(
          context,
          listen: false,
        ).fetchPlacesApi(widget.searchQuery!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discoveryViewModel = Provider.of<DiscoveryViewModel>(context);

    // Notification for search results
    final currentStatus =
        discoveryViewModel.placesList.status ?? Status.initial;
    if (currentStatus != _lastStatus) {
      _lastStatus = currentStatus;

      if (currentStatus == Status.success) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final count = discoveryViewModel.placesList.data?.length ?? 0;
          Utils.flushBarSuccessMessage(
            "Found $count places in ${_searchController.text}",
            context,
          );
        });
      } else if (currentStatus == Status.error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Utils.flushBarErrorMessage(
            discoveryViewModel.placesList.message ?? "Failed to fetch places",
            context,
          );
        });
      }
    }

    // Programmatic search from main tab
    if (discoveryViewModel.programmaticSearchQuery != null) {
      final query = discoveryViewModel.programmaticSearchQuery!;
      Future.microtask(() {
        _searchController.text = query;
        discoveryViewModel.fetchPlacesApi(query);
        discoveryViewModel.setProgrammaticSearchQuery(null);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header and Search Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      "Explore",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const Text(
                      "Beautiful Places",
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColors.textColorSecondary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Search Bar with Shadow isolation
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _filterController.clear();
                            discoveryViewModel.fetchPlacesApi(value);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Search destinations...",
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primaryColor,
                          ),
                          suffixIcon:
                              _searchController.text.isNotEmpty ||
                                  discoveryViewModel.placesList.status !=
                                      Status.initial
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterController.clear();
                                    discoveryViewModel.clearSearch();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildFilterSection(discoveryViewModel),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Dynamic Results Section
            ..._buildResultsSlivers(discoveryViewModel),

            // Trending Destinations (only shown initially)
            if (discoveryViewModel.placesList.status == Status.initial)
              ..._buildTrendingSlivers(discoveryViewModel),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResultsSlivers(DiscoveryViewModel viewModel) {
    switch (viewModel.placesList.status) {
      case Status.loading:
        return _buildShimmerSlivers();

      case Status.error:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text("Error: ${viewModel.placesList.message}"),
            ),
          ),
        ];

      case Status.success:
        final allPlaces = viewModel.placesList.data ?? [];
        final filterText = _filterController.text.toLowerCase();
        final places = allPlaces.where((place) {
          return (place.name ?? "").toLowerCase().contains(filterText);
        }).toList();

        if (allPlaces.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: const Center(child: Text("No places found.")),
            ),
          ];
        }

        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Places in ${_searchController.text}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Filter Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _filterController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: "Filter places by name...",
                        prefixIcon: const Icon(
                          Icons.filter_list,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                        suffixIcon: _filterController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _filterController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (places.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text("No places match your filter."),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Virtualized List of results
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final place = places[index];
                  return _buildPlaceCard(place);
                },
                childCount: places.length > viewModel.visibleCount
                    ? viewModel.visibleCount
                    : places.length,
              ),
            ),
          ),

          // Load More Section
          if (places.length > viewModel.visibleCount)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      "Showing ${viewModel.visibleCount > places.length ? places.length : viewModel.visibleCount} of ${places.length} results",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () => viewModel.loadMore(),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text(
                        "Load More",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: Center(
              child: TextButton(
                onPressed: () {
                  _searchController.clear();
                  viewModel.clearSearch();
                },
                child: const Text("Clear Search"),
              ),
            ),
          ),
        ];

      default:
        return [const SliverToBoxAdapter(child: SizedBox())];
    }
  }

  Widget _buildPlaceCard(PlaceModel place) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, RoutesName.placeDetails, arguments: place);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Utils.getKindIcon(place.kind),
                size: 32,
                color: AppColors.primaryColor.withOpacity(0.7),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      place.name ?? "Unknown Place",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          place.kind?.split(',').first.replaceAll('_', ' ') ??
                              "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textColorSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.primaryColor,
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
    );
  }

  List<Widget> _buildShimmerSlivers() {
    return [
      SliverToBoxAdapter(
        child: Shimmer(
          duration: ShimmerWidget.defaultDuration,
          interval: ShimmerWidget.defaultInterval,
          color: ShimmerWidget.highlightColor,
          colorOpacity: 0.3,
          enabled: true,
          direction: const ShimmerDirection.fromLTRB(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Title Placeholder: "Places in..."
                const ShimmerWidget.rectangular(height: 25, width: 180),
                const SizedBox(height: 15),

                // Filter Search Bar Placeholder
                ShimmerWidget.rectangular(
                  height: 50,
                  width: double.infinity,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 25),

                // Skeleton Cards
                ...List.generate(
                  4,
                  (index) => Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    height: 100,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Row(
                      children: [
                        // Icon Placeholder (Matching the 32px icon in real card)
                        ShimmerWidget.rectangular(
                          height: 40,
                          width: 40,
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Name Placeholder (18px bold in real card)
                              const ShimmerWidget.rectangular(
                                height: 20,
                                width: 140,
                              ),
                              const SizedBox(height: 8),
                              // Kind + Arrow Row
                              Row(
                                children: [
                                  // Kind Placeholder (14px in real card)
                                  const ShimmerWidget.rectangular(
                                    height: 14,
                                    width: 80,
                                  ),
                                  const Spacer(),
                                  const Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey,
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
              ],
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildTrendingSlivers(DiscoveryViewModel viewModel) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Trending Destinations",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        sliver: SliverGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 0.8,
          children: [
            _buildTrendingCard(
              viewModel,
              "Ladakh",
              "India",
              "https://images.unsplash.com/photo-1619837374214-f5b9eb80876d?q=80&w=687&auto=format&fit=crop",
            ),
            _buildTrendingCard(
              viewModel,
              "Hampi",
              "India",
              "https://images.unsplash.com/photo-1616606484004-5ef3cc46e39d?q=80&w=1170&auto=format&fit=crop",
            ),
            _buildTrendingCard(
              viewModel,
              "Udaipur",
              "India",
              "https://images.unsplash.com/photo-1695956353120-54ce5e91632b?q=80&w=735&auto=format&fit=crop",
            ),
            _buildTrendingCard(
              viewModel,
              "Munnar",
              "India",
              "https://images.unsplash.com/photo-1709749377610-c91fc5fea3f6?q=80&w=735&auto=format&fit=crop",
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildTrendingCard(
    DiscoveryViewModel viewModel,
    String title,
    String location,
    String imageUrl,
  ) {
    return InkWell(
      onTap: () {
        _searchController.text = title;
        viewModel.fetchPlacesApi(title);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                cacheWidth: 400, // Optimize memory for 120Hz buffers
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
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
    );
  }

  final List<Map<String, String>> _categories = [
    {'name': 'All', 'kind': ''},
    {'name': 'Historical', 'kind': 'historic'},
    {'name': 'Natural', 'kind': 'natural'},
    {'name': 'Cultural', 'kind': 'cultural'},
    {'name': 'Religion', 'kind': 'religion'},
    {'name': 'Architecture', 'kind': 'architecture'},
    {'name': 'Industrial', 'kind': 'industrial_facilities'},
    {'name': 'Other', 'kind': 'other'},
  ];

  Widget _buildFilterSection(DiscoveryViewModel viewModel) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category['kind']!.isEmpty
              ? viewModel.selectedKinds.isEmpty
              : viewModel.selectedKinds.contains(category['kind']);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(category['name']!),
              selected: isSelected,
              onSelected: (bool selected) {
                viewModel.toggleSelectedKind(
                  category['kind']!,
                  _searchController.text,
                );
              },
              backgroundColor: AppColors.whiteColor,
              selectedColor: AppColors.primaryColor.withOpacity(0.2),
              checkmarkColor: AppColors.primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.blackColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey[300]!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
