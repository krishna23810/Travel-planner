import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_planner/data/response/status.dart';
import 'package:travel_planner/view_modal/weather_view_modal.dart';
import '../model/place_model.dart';
import '../res/colors.dart';
import '../repository/discovery_repository.dart';

import '../res/components/shimmer_widget.dart';

import 'package:travel_planner/view_modal/trip_view_modal.dart';
import 'package:travel_planner/utils/utils.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final PlaceModel place;
  const PlaceDetailsScreen({super.key, required this.place});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  late Future<PlaceModel> _detailsFuture;
  final DiscoveryRepository _repository = DiscoveryRepository();

  @override
  void initState() {
    super.initState();
    // Fetch full details of the place when the screen loads
    _detailsFuture = _repository.getPlaceDetails(widget.place.xid ?? "");

    // Fetch weather data
    if (widget.place.lat != null && widget.place.lon != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<WeatherViewModel>(
          context,
          listen: false,
        ).fetchWeatherApi(widget.place.lat!, widget.place.lon!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("PlaceDetailsScreen: Building UI with details: ${widget.place.toJson()}");
    final tripViewModel = Provider.of<TripViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<PlaceModel>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildMainShimmer();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Error loading details: ${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _detailsFuture = _repository.getPlaceDetails(
                          widget.place.xid ?? "",
                        );
                      });
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final place = snapshot.data ?? widget.place;

          return CustomScrollView(
            slivers: [
              // Header with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      place.image != null
                          ? Image.network(place.image!, fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.landscape,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                      // Dark Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    place.name ?? "Details",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kinds / Categories
                      if (place.kind != null)
                        Wrap(
                          spacing: 8,
                          children: place.kind!
                              .split(',')
                              .take(5)
                              .map(
                                (k) => Chip(
                                  label: Text(
                                    k.replaceAll('_', ' ').toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: AppColors.primaryColor,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: 20),

                      // Rating & Source
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            "Top Rated Destination",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      _buildWeatherSection(context),

                      const SizedBox(height: 30),

                      // Description
                      const Text(
                        "Overview",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        place.description ??
                            "No description available for this destination.",
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            _showTripSelectionDialog(
                              context,
                              tripViewModel,
                              place,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Add to Itinerary",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeatherSection(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, viewModel, child) {
        switch (viewModel.weatherData.status) {
          case Status.loading:
            return _buildWeatherShimmer();
          case Status.error:
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "Could not load weather: ${viewModel.weatherData.message}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          case Status.success:
            final weather = viewModel.weatherData.data!;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Weather Icon
                  Image.network(
                    'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                    width: 60,
                    height: 60,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.wb_sunny,
                      size: 40,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Temp and Logic
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${weather.temp.round()}°C",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackColor,
                          ),
                        ),
                        Text(
                          weather.description.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textColorSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Humidity & Wind
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.water_drop,
                            size: 14,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${weather.humidity}%",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.air, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "${weather.windSpeed} m/s",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          case Status.initial:
          default:
            return const SizedBox();
        }
      },
    );
  }

  Widget _buildMainShimmer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const ShimmerWidget.rectangular(height: 300),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerWidget.rectangular(height: 30, width: 250),
                const SizedBox(height: 15),
                Row(
                  children: List.generate(
                    3,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: const ShimmerWidget.rectangular(
                        height: 25,
                        width: 80,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const ShimmerWidget.rectangular(height: 20, width: 200),
                const SizedBox(height: 30),
                const ShimmerWidget.rectangular(height: 25, width: 120),
                const SizedBox(height: 15),
                const ShimmerWidget.rectangular(height: 100),
                const SizedBox(height: 30),
                const ShimmerWidget.rectangular(height: 55),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherShimmer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          ShimmerWidget.circular(height: 60, width: 60),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rectangular(height: 30, width: 80),
                SizedBox(height: 10),
                ShimmerWidget.rectangular(height: 15, width: 120),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerWidget.rectangular(height: 15, width: 50),
              SizedBox(height: 10),
              ShimmerWidget.rectangular(height: 15, width: 70),
            ],
          ),
        ],
      ),
    );
  }

  void _showTripSelectionDialog(
    BuildContext context,
    TripViewModel viewModel,
    PlaceModel place,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add to Itinerary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (viewModel.trips.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("You haven't created any trips yet."),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: viewModel.trips.length,
                    itemBuilder: (listContext, index) {
                      final trip = viewModel.trips[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.travel_explore,
                          color: AppColors.primaryColor,
                        ),
                        title: Text(trip.title),
                        subtitle: Text(
                          "${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year} • ${trip.durationDays} days",
                        ),
                        onTap: () {
                          viewModel.addPlaceToTrip(trip.id, place);
                          Navigator.pop(sheetContext);
                          Utils.flushBarSuccessMessage("Added to Trip!", context);
                        },
                      );
                    },
                  ),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add, color: AppColors.primaryColor),
                title: const Text(
                  "Create New Trip",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateTripDialog(context, viewModel, place);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateTripDialog(
    BuildContext context,
    TripViewModel viewModel,
    PlaceModel place,
  ) {
    final titleController = TextEditingController();
    final daysController = TextEditingController(text: "1");
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("New Trip"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Trip Title (e.g. Summer Vacation)",
                      labelText: "Title",
                    ),
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20, color: AppColors.primaryColor),
                          const SizedBox(width: 10),
                          Text(
                            selectedDate == null
                                ? "Select Start Date"
                                : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                            style: TextStyle(
                              color: selectedDate == null ? Colors.grey[600] : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: daysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Number of Days",
                      hintText: "e.g. 7",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty && selectedDate != null) {
                      final days = int.tryParse(daysController.text) ?? 1;
                      final newTripId = await viewModel.createTrip(
                        titleController.text,
                        selectedDate!,
                        days,
                      );
                      // Automatically add the place to the newly created trip
                      await viewModel.addPlaceToTrip(newTripId, place);

                      if (context.mounted) {
                        Navigator.pop(context);
                        Utils.flushBarSuccessMessage("Trip Created and Place Added!", context);
                      }
                    } else if (selectedDate == null) {
                      Utils.flushBarErrorMessage("Please select a start date", context);
                    }
                  },
                  child: const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
