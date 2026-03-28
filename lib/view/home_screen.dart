import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_planner/utils/routes/routes_name.dart';
import '../model/trip_model.dart';

import 'package:travel_planner/view_modal/trip_view_modal.dart';

import 'package:travel_planner/view_modal/user_view_modal.dart';
import 'package:travel_planner/view_modal/discovery_view_modal.dart';
import 'package:travel_planner/view_modal/main_view_model.dart';
import 'package:travel_planner/res/colors.dart';
import 'package:travel_planner/res/components/shimmer_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user data on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserViewModel>(context, listen: false).getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome back,",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textColorSecondary,
                          ),
                        ),
                        FutureBuilder(
                          future: userViewModel.getUser(),
                          builder: (context, snapshot) {
                            String name = "Explorer";
                            if (snapshot.hasData &&
                                snapshot.data!.name != null &&
                                snapshot.data!.name!.isNotEmpty) {
                              name = snapshot.data!.name!.split(
                                ' ',
                              )[0]; // first name
                            }
                            return Text(
                              "Hello, $name!",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blackColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                        "https://images.unsplash.com/photo-1528892952291-009c663ce843?q=80&w=644&auto=format&fit=crop",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Explore Top Destinations",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<MainViewModel>(
                          context,
                          listen: false,
                        ).setSelectedIndex(1);
                      },
                      child: const Text(
                        "See all",
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 300,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildDestinationCard(
                        "Goa",
                        "India",
                        "https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?q=80&w=1000&auto=format&fit=crop",
                      ),
                      _buildDestinationCard(
                        "manali",
                        "Himachal Pradesh",
                        "https://images.unsplash.com/photo-1593181629936-11c609b8db9b?q=80&w=1074&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                      ),
                      _buildDestinationCard(
                        "Munnar",
                        "Kerala",
                        "https://images.unsplash.com/photo-1580818135730-ebd11086660b?q=80&w=1157&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                      ),
                      _buildDestinationCard(
                        "Jaipur",
                        "Rajasthan",
                        "https://images.unsplash.com/photo-1599661046289-e31897846e41?q=80&w=1000&auto=format&fit=crop",
                      ),
                      _buildDestinationCard(
                        "Varanasi",
                        "Uttar Pradesh",
                        "https://images.unsplash.com/photo-1561359313-0639aad49ca6?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Trips",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RoutesName.tripList);
                      },
                      child: const Text(
                        "See all",
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Consumer<TripViewModel>(
                  builder: (context, tripViewModel, child) {
                    if (tripViewModel.trips.isEmpty) {
                      return const Center(
                        child: Text(
                          "No trips planned yet.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tripViewModel.trips.length > 3
                          ? 3
                          : tripViewModel.trips.length,
                      itemBuilder: (context, index) {
                        final trip = tripViewModel.trips[index];
                        return _buildTripItem(context, trip, tripViewModel);
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard(String title, String location, String imageUrl) {
    return InkWell(
      onTap: () {
        Provider.of<DiscoveryViewModel>(
          context,
          listen: false,
        ).setProgrammaticSearchQuery(title);
        Provider.of<MainViewModel>(context, listen: false).setSelectedIndex(1);
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Image with Shimmer/Fallback
              ShimmerImage(
                imageUrl: imageUrl,
                fallbackText: title,
                width: 180,
                height: 300,
              ),
              // Dark overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
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

  Widget _buildTripItem(
    BuildContext context,
    TripModel trip,
    TripViewModel tripViewModel,
  ) {
    final totalPlaces = trip.places.length;
    final visitedPlaces = trip.places
        .where((p) => p['isVisited'] == true)
        .length;

    return InkWell(
      onTap: () {
        tripViewModel.setExpandedTripId(trip.id);
        Provider.of<MainViewModel>(context, listen: false).setSelectedIndex(2);
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.blackColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "${trip.startDate.day}/${trip.startDate.month} • ${trip.durationDays} days",
                      style: const TextStyle(
                        color: AppColors.textColorSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "$totalPlaces places • $visitedPlaces visited",
                      style: TextStyle(
                        color: totalPlaces == visitedPlaces && totalPlaces > 0
                            ? Colors.green
                            : AppColors.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textColorSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
