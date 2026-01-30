import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../viewmodels/stores_viewmodel.dart';
import '../widgets/error_widget.dart';
import '../config/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // Initialize location if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<StoresViewModel>();
      if (!viewModel.hasLocation && viewModel.locationStatus == LocationStatus.initial) {
        viewModel.initializeLocation();
      }
    });
  }

  void _recenterMap(StoresViewModel viewModel) {
    if (viewModel.currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              viewModel.currentPosition!.latitude,
              viewModel.currentPosition!.longitude,
            ),
            zoom: 14,
          ),
        ),
      );
    }
  }

  Set<Marker> _buildMarkers(StoresViewModel viewModel) {
    return viewModel.stores.map((store) {
      return Marker(
        markerId: MarkerId(store.id),
        position: store.coordinate,
        infoWindow: InfoWindow(
          title: store.name,
          snippet: store.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nearby Stores',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<StoresViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.hasLocation && !viewModel.isLoadingStores) {
                return IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: AppTheme.primaryGold,
                  ),
                  onPressed: () => viewModel.refreshStores(),
                  tooltip: 'Refresh stores',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<StoresViewModel>(
        builder: (context, viewModel, child) {
          // Loading state
          if (viewModel.isLoadingLocation) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryGold),
                  const SizedBox(height: 20),
                  Text(
                    'Getting your location...',
                    style: TextStyle(
                      color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }

          // Error state
          if (viewModel.hasError && !viewModel.hasLocation) {
            return ErrorDisplayWidget(
              error: viewModel.error,
              onRetry: viewModel.canRetry ? () => viewModel.retry() : null,
            );
          }

          // Map and stores list
          if (viewModel.hasLocation) {
            return Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                viewModel.currentPosition!.latitude,
                                viewModel.currentPosition!.longitude,
                              ),
                              zoom: 14,
                            ),
                            markers: _buildMarkers(viewModel),
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            onMapCreated: (controller) {
                              _mapController = controller;
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        right: 30,
                        child: FloatingActionButton(
                          onPressed: () => _recenterMap(viewModel),
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: AppTheme.backgroundDark,
                          elevation: 2,
                          child: const Icon(Icons.my_location_rounded),
                        ),
                      ),
                      if (viewModel.isLoadingStores)
                        Positioned(
                          top: 30,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.textMuted.withValues(alpha: 0.2)
                                      : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primaryGold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Finding stores...',
                                    style: TextStyle(
                                      color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? AppTheme.textMuted.withValues(alpha: 0.15)
                              : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: viewModel.stores.isEmpty
                        ? viewModel.hasError && !viewModel.isLoadingStores
                            ? ErrorDisplayWidget(
                                error: viewModel.error,
                                compact: true,
                                onRetry: viewModel.canRetry ? () => viewModel.retry() : null,
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      viewModel.isLoadingStores
                                          ? Icons.search_rounded
                                          : Icons.store_mall_directory_outlined,
                                      size: 36,
                                      color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      viewModel.isLoadingStores
                                          ? 'Searching for stores...'
                                          : 'No stores found nearby',
                                      style: TextStyle(
                                        color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.store_rounded,
                                      size: 18,
                                      color: AppTheme.primaryGold,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'NEARBY STORES',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 2,
                                        color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGold.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${viewModel.stores.length}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryGold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: viewModel.stores.length,
                                  itemBuilder: (context, index) {
                                    final store = viewModel.stores[index];
                                    final miles = (store.distance ?? 0) * 0.000621371;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            _mapController?.animateCamera(
                                              CameraUpdate.newLatLng(store.coordinate),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppTheme.backgroundDark
                                                  : AppTheme.lightBackground,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isDark
                                                    ? AppTheme.textMuted.withValues(alpha: 0.15)
                                                    : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.primaryGold.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(
                                                    Icons.liquor_rounded,
                                                    size: 20,
                                                    color: AppTheme.primaryGold,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        store.name,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 14,
                                                          color: isDark
                                                              ? AppTheme.textPrimary
                                                              : AppTheme.lightTextPrimary,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        store.address,
                                                        style: TextStyle(
                                                          color: isDark
                                                              ? AppTheme.textMuted
                                                              : AppTheme.lightTextSecondary,
                                                          fontSize: 12,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${miles.toStringAsFixed(1)} mi',
                                                  style: TextStyle(
                                                    color: AppTheme.primaryGold,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            );
          }

          // Initial state
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGold),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
