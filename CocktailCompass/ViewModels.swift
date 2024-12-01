//
//  ViewModels.swift
//  CocktailCompass
//
//  Created by McTyler Tong on 10/22/24.
//

import SwiftUI
import Combine
import MapKit
import CoreLocation

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var drinks: [Drink] = []
    @Published var isLoading = false
    @Published var favoritedDrinkIDs: Set<String> = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchFavoritedDrinkIDs()
    }
    
    func fetchFavoritedDrinkIDs() {
        let favoritedDrinks = CoreDataManager.shared.fetchFavoritedDrinks()
        favoritedDrinkIDs = Set(favoritedDrinks.map { $0.id })
    }
    
    func toggleFavorite(drink: Drink) {
        if favoritedDrinkIDs.contains(drink.id) {
            CoreDataManager.shared.deleteFavoritedDrink(drink)
            favoritedDrinkIDs.remove(drink.id)
        } else {
            CoreDataManager.shared.addFavoritedDrink(drink)
            favoritedDrinkIDs.insert(drink.id)
        }
    }
    
    func searchDrinks() {
        guard !query.isEmpty else { return }
        isLoading = true
        DrinkAPIService.fetchDrinks(query: query)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
            } receiveValue: { drinks in
                self.drinks = drinks
            }
            .store(in: &cancellables)
    }
}

class IngredientsViewModel: ObservableObject {
    @Published var ingredient: String = ""
    @Published var drinks: [Drink] = []
    @Published var isLoading = false
    @Published var favoritedDrinkIDs: Set<String> = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchFavoritedDrinkIDs()
    }
    
    func fetchFavoritedDrinkIDs() {
        let favoritedDrinks = CoreDataManager.shared.fetchFavoritedDrinks()
        favoritedDrinkIDs = Set(favoritedDrinks.map { $0.id })
    }
    
    func toggleFavorite(drink: Drink) {
        if favoritedDrinkIDs.contains(drink.id) {
            CoreDataManager.shared.deleteFavoritedDrink(drink)
            favoritedDrinkIDs.remove(drink.id)
        } else {
            CoreDataManager.shared.addFavoritedDrink(drink)
            favoritedDrinkIDs.insert(drink.id)
        }
    }
    
    func fetchDrinksByIngredient() {
        guard !ingredient.isEmpty else { return }
        isLoading = true
        DrinkAPIService.fetchDrinksByIngredient(ingredient)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
            } receiveValue: { drinks in
                self.drinks = drinks
            }
            .store(in: &cancellables)
    }
}

class FavoritesViewModel: ObservableObject {
    @Published var favoritedDrinks: [Drink] = []
    @Published var favoritedDrinkIDs: Set<String> = []

    func loadFavorites() {
        let fetchedDrinks = CoreDataManager.shared.fetchFavoritedDrinks()
        favoritedDrinks = fetchedDrinks.isEmpty ? [] : fetchedDrinks
        favoritedDrinkIDs = Set(fetchedDrinks.map { $0.id })
    }

    func removeFavorite(drink: Drink) {
        CoreDataManager.shared.deleteFavoritedDrink(drink)
        loadFavorites()
    }
}

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    @Published var stores: [Store] = []
    @Published var showLocationAlert = false
    @Published var selectedStore: Store?
    @Published var userLocation: CLLocation?
    var isUserInteractingWithMap: Bool = false

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        requestLocationPermission()
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func recenterMap() {
        guard let userLocation = userLocation else {
            print("User location is not available.")
            return
        }
        
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: userLocation.coordinate,
                latitudinalMeters: 1609.34,
                longitudinalMeters: 1609.34
            )
        }
    }

    func searchNearbyStores() {
        guard let userLocation = self.userLocation else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Grocery Store, Liquor Store"
        request.region = MKCoordinateRegion(
            center: userLocation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Error searching for stores: \(error.localizedDescription)")
                return
            }

            guard let response = response else { return }

            let mapItems = response.mapItems
            let fetchedStores = mapItems.compactMap { item -> Store? in
                guard let name = item.name else { return nil }
                let storeCoordinate = item.placemark.coordinate
                let storeLocation = CLLocation(latitude: storeCoordinate.latitude, longitude: storeCoordinate.longitude)
                let distance = userLocation.distance(from: storeLocation)

                return Store(
                    name: name,
                    address: item.placemark.title ?? "No Address",
                    coordinate: storeCoordinate,
                    distance: distance
                )
            }

            let sortedStores = fetchedStores.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }

            DispatchQueue.main.async {
                self.stores = sortedStores
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Authorization granted. Starting location updates.")
            startUpdatingLocation()
        case .denied, .restricted:
            print("Authorization denied or restricted.")
            DispatchQueue.main.async {
                self.showLocationAlert = true
            }
        case .notDetermined:
            print("Authorization not determined. Requesting when-in-use authorization.")
            manager.requestWhenInUseAuthorization()
        @unknown default:
            print("Unknown authorization status.")
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        DispatchQueue.main.async {
            self.userLocation = location

            if !self.isUserInteractingWithMap {
                self.region = MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: 1609.34,
                    longitudinalMeters: 1609.34
                )
            }
            self.searchNearbyStores()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}




class DrinkDetailViewModel: ObservableObject {
    @Published var drink: Drink

    private var cancellables = Set<AnyCancellable>()

    init(drink: Drink) {
        self.drink = drink
        if drink.ingredients.isEmpty {
            fetchDrinkDetails()
        }
    }

    func fetchDrinkDetails() {
        DrinkAPIService.fetchDrinkDetails(by: drink.id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("Error fetching drink details: \(error.localizedDescription)")
                }
            } receiveValue: { detailedDrink in
                self.drink = detailedDrink
            }
            .store(in: &cancellables)
    }
}
