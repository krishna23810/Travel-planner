import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_planner/res/colors.dart';
import 'package:travel_planner/view_modal/trip_view_modal.dart';
import 'package:travel_planner/model/trip_model.dart';
import 'package:travel_planner/utils/routes/routes_name.dart';

import 'package:travel_planner/model/place_model.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../res/components/shimmer_widget.dart';

class TripListScreen extends StatelessWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: AppBar(
        title: const Text(
          "My Trips",

          style: TextStyle(
            color: AppColors.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTripDialog(context),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<TripViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.loading) {
            return _buildShimmerLoading();
          }

          if (viewModel.trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.travel_explore, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  const Text(
                    "No trips planned yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: viewModel.trips.length,
            itemBuilder: (context, index) {
              final trip = viewModel.trips[index];
              final isExpanded = trip.id == viewModel.expandedTripId;

              return _buildTripCard(context, trip, viewModel, isExpanded);
            },
          );
        },
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context,
    TripModel trip,
    TripViewModel viewModel,
    bool isExpanded,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          // Header Section
          InkWell(
            onTap: () {
              viewModel.setExpandedTripId(isExpanded ? null : trip.id);
            },
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(28),
              topRight: const Radius.circular(28),
              bottomLeft: Radius.circular(isExpanded ? 0 : 28),
              bottomRight: Radius.circular(isExpanded ? 0 : 28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: AppColors.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Title and Meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            color: AppColors.textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Metadata Wrap to prevent overlap
                        Row(
                          children: [
                            _buildMetaItem(
                              Icons.calendar_today_rounded,
                              "${trip.startDate.day}/${trip.startDate.month}",
                            ),
                            _buildMetaItem(
                              Icons.timer_outlined,
                              "${trip.durationDays}d",
                            ),
                            _buildMetaItem(
                              Icons.location_on_outlined,
                              "${trip.places.length}",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeaderAction(
                            icon: Icons.edit_rounded,
                            color: AppColors.primaryColor,
                            onTap: () => _showTripDialog(context, trip: trip),
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderAction(
                            icon: Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                            onTap: () =>
                                _confirmDelete(context, trip, viewModel),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable Body
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildTripPlacesList(context, trip, viewModel),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    TripModel trip,
    TripViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Delete Trip",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("This itinerary will be removed. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Keep it"),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.removeTrip(trip.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildTripPlacesList(
    BuildContext context,
    TripModel trip,
    TripViewModel viewModel,
  ) {
    if (trip.places.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: Text(
          "No places added to this trip yet.",
          style: TextStyle(color: AppColors.textColorSecondary, fontSize: 14),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: trip.places.length,
        itemBuilder: (context, index) {
          final item = trip.places[index];
          final place = item['place'] as PlaceModel;
          final isVisited = item['isVisited'] as bool;
          final isFirst = index == 0;
          final isLast = index == trip.places.length - 1;

          return _buildTimelinePlaceItem(
            context,
            trip,
            viewModel,
            place,
            isVisited,
            isFirst,
            isLast,
          );
        },
      ),
    );
  }

  Widget _buildTimelinePlaceItem(
    BuildContext context,
    TripModel trip,
    TripViewModel viewModel,
    PlaceModel place,
    bool isVisited,
    bool isFirst,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 30),
          // Timeline indicator
          Column(
            children: [
              Expanded(
                child: Container(
                  width: 2,
                  color: isFirst ? Colors.transparent : Colors.grey[200],
                ),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isVisited ? AppColors.accentColor : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    if (isVisited)
                      BoxShadow(
                        color: AppColors.accentColor.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                  ],
                ),
              ),
              // if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : Colors.grey[200],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Place Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4, right: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RoutesName.placeDetails,
                    arguments: place,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isVisited ? Colors.grey[50] : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isVisited ? Colors.grey[100]! : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: place.image != null
                            ? Image.network(
                                place.image!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                color: isVisited
                                    ? Colors.grey.withOpacity(0.4)
                                    : null,
                                colorBlendMode: isVisited
                                    ? BlendMode.saturation
                                    : null,
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                color: AppColors.primaryColor.withOpacity(0.05),
                                child: Icon(
                                  Icons.place_rounded,
                                  color: AppColors.primaryColor.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name ?? "Unknown Place",
                              style: TextStyle(
                                fontWeight: isVisited
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                fontSize: 16,
                                color: isVisited
                                    ? AppColors.textColorSecondary
                                    : AppColors.textColor,
                                decoration: isVisited
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            Text(
                              place.kind
                                      ?.split(',')
                                      .first
                                      .replaceAll('_', ' ') ??
                                  "",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textColorSecondary.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: isVisited,
                        activeColor: AppColors.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        onChanged: (val) =>
                            viewModel.togglePlaceVisited(trip.id, place.xid!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer(
      duration: ShimmerWidget.defaultDuration,
      interval: ShimmerWidget.defaultInterval,
      color: ShimmerWidget.highlightColor,
      colorOpacity: 0.3,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  ShimmerWidget.rectangular(height: 50, width: 50),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerWidget.rectangular(height: 20, width: 150),
                        SizedBox(height: 10),
                        ShimmerWidget.rectangular(height: 15, width: 200),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textColorSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textColorSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showTripDialog(BuildContext context, {TripModel? trip}) {
    final viewModel = Provider.of<TripViewModel>(context, listen: false);
    final isEditing = trip != null;

    final titleController = TextEditingController(text: trip?.title ?? "");
    final durationController = TextEditingController(
      text: trip?.durationDays.toString() ?? "1",
    );
    DateTime selectedDate = trip?.startDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? "Edit Trip" : "Create New Trip"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Trip Title",
                    hintText: "e.g. Summer in Manali",
                  ),
                ),
                const SizedBox(height: 15),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Start Date"),
                  subtitle: Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today, size: 20),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null && picked != selectedDate) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: "Duration (Days)",
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final duration = int.tryParse(durationController.text) ?? 1;

                if (title.isNotEmpty) {
                  if (isEditing) {
                    viewModel.updateTrip(
                      trip.id,
                      title,
                      selectedDate,
                      duration,
                    );
                  } else {
                    viewModel.createTrip(title, selectedDate, duration);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? "Save" : "Create"),
            ),
          ],
        ),
      ),
    );
  }
}
