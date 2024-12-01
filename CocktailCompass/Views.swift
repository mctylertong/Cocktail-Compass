//
//  Views.swift
//  CocktailCompass
//
//  Created by McTyler Tong on 10/22/24.
//

import SwiftUI
import MapKit

struct LoadingPage: View {
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()

            VStack {
                Spacer()

                Text("COCKTAIL")
                    .font(.system(size: 60))
                    .foregroundColor(.black)
                    .bold()
                Text("COMPASS")
                    .font(.system(size: 60))
                    .foregroundColor(.black)
                    .bold()

                Image("compass")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)

                Spacer()
            }
        }
    }
}

struct RootView: View {
    @State private var showLoading = true
    @StateObject var favoritesViewModel = FavoritesViewModel()

    var body: some View {
        if showLoading {
            LoadingPage()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showLoading = false
                    }
                }
        } else {
            ContentView()
                .environmentObject(favoritesViewModel)
        }
    }
}

struct HomePage: View {
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()

            VStack {
                Text("Home")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .bold()
                
                Spacer()

                Text("Know what you want to drink?")
                    .font(.title)
                    .foregroundColor(.black)

                NavigationLink(destination: SearchPage()) {
                    Text("Proceed to Search for Drinks")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }

                Text("Want to try something new?")
                    .font(.title)
                    .foregroundColor(.black)

                NavigationLink(destination: IngredientsPage()) {
                    Text("Proceed to Enter an Ingredient")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }

                Spacer()
                Spacer()
            }
            .padding()
        }
    }
}

struct SearchPage: View {
    @State private var searchText = ""

    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()

            VStack {
                Text("Search for a Drink")
                    .font(.title)
                    .padding(.bottom, 20)

                TextField("e.g. Old Fashion, Margarita", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                NavigationLink(destination: SearchResultsPage(query: searchText)) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

struct SearchResultsPage: View {
    let query: String
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            VStack {
                Text("Results Based on Your Drink Search")
                    .font(.title2)
                    .padding(.bottom, 20)
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if viewModel.drinks.isEmpty {
                    Text("No results found for '\(query)'")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.drinks) { drink in
                            DrinkRow(
                                drink: drink,
                                isFavorited: viewModel.favoritedDrinkIDs.contains(drink.id),
                                showHeartButton: true, 
                                toggleFavoriteAction: { viewModel.toggleFavorite(drink: drink) }
                            )
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.gray)
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back to Search")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            .padding()
            .onAppear {
                viewModel.query = query
                viewModel.searchDrinks()
            }
        }
    }
}

struct IngredientsPage: View {
    @State private var ingredientsText = ""

    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()

            VStack {
                Text("Enter an Ingredient")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)

                TextField("e.g. Whiskey, Tequila, Lemonade", text: $ingredientsText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                NavigationLink(destination: IngredientResultsPage(ingredient: ingredientsText)) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

struct IngredientResultsPage: View {
    let ingredient: String
    @StateObject private var viewModel = IngredientsViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            
            VStack {
                Text("Results Based on Your Ingredient")
                    .font(.title2)
                    .padding(.bottom, 20)
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if viewModel.drinks.isEmpty {
                    Text("No results found for the ingredient: \(ingredient)")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.drinks) { drink in
                        let isFavorited = viewModel.favoritedDrinkIDs.contains(drink.id)
                        DrinkRow(
                            drink: drink,
                            isFavorited: isFavorited,
                            showHeartButton: true,
                            toggleFavoriteAction: {
                                viewModel.toggleFavorite(drink: drink)
                            }
                        )
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.gray)
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back to Ingredients")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            .padding()
            .onAppear {
                viewModel.ingredient = ingredient
                viewModel.fetchDrinksByIngredient()
            }
        }
    }
}

struct FavoritedDrinksPage: View {
    @EnvironmentObject var viewModel: FavoritesViewModel

    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            
            VStack {
                Text("Favorite Drinks")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .bold()
                
                if viewModel.favoritedDrinks.isEmpty {
                    Text("No favorited drinks yet!")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.favoritedDrinks) { drink in
                            DrinkRow(
                                drink: drink,
                                isFavorited: true,
                                showHeartButton: false,
                                toggleFavoriteAction: {
                                }
                            )
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let drink = viewModel.favoritedDrinks[index]
                                viewModel.removeFavorite(drink: drink)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.gray)
                }
            }
            .onAppear {
                viewModel.loadFavorites()
            }
        }
    }
}

struct MapPage: View {
    @StateObject private var locationManager = MapViewModel()
    @State private var userTrackingMode: MapUserTrackingMode = .none

    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()

            VStack {
                Text("Stores Near You")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .bold()
                    .padding(.bottom, 20)

                ZStack {
                    Map(
                        coordinateRegion: $locationManager.region,
                        showsUserLocation: true,
                        annotationItems: locationManager.stores
                    ) { store in
                        MapAnnotation(coordinate: store.coordinate) {
                            VStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title)
                                Text(store.name)
                                    .foregroundColor(.black)
                                    .font(.caption)
                                    .fixedSize()
                            }
                            .onTapGesture {
                                locationManager.selectedStore = store
                            }
                        }
                    }
                    .frame(height: 400)
                    .cornerRadius(10)
                    .padding()
                    .gesture(
                        DragGesture()
                            .onChanged { _ in
                                locationManager.isUserInteractingWithMap = true
                            }
                            .onEnded { _ in
                                locationManager.isUserInteractingWithMap = false
                            }
                    )
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                locationManager.recenterMap()
                            }) {
                                Image(systemName: "location.fill")
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }

                if !locationManager.stores.isEmpty {
                    List(locationManager.stores) { store in
                        HStack {
                            Text(store.name)
                                .font(.headline)
                            Spacer()
                            if let distance = store.distance {
                                let miles = distance / 1609.34
                                Text(String(format: "%.2f miles", miles))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: 200)
                } else {
                    Text("No stores found nearby.")
                        .foregroundColor(.gray)
                        .padding()
                }

                Spacer()
            }
            .alert(isPresented: $locationManager.showLocationAlert) {
                Alert(
                    title: Text("Location Access Denied"),
                    message: Text("Enable location permissions in settings to view nearby stores."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}



struct DrinkRow: View {
    let drink: Drink
    let isFavorited: Bool
    let showHeartButton: Bool
    let toggleFavoriteAction: () -> Void

    var body: some View {
        HStack {
            NavigationLink(destination: DrinkDetailPage(drink: drink)) {
                HStack {
                    if let urlString = drink.thumbnailURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(5)
                        } placeholder: {
                            ProgressView()
                        }
                    }

                    Text(drink.name)
                        .font(.headline)

                    Spacer()
                }
                .padding(.vertical, 5)
            }
            .buttonStyle(PlainButtonStyle())

            if showHeartButton {
                Button(action: toggleFavoriteAction) {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .foregroundColor(isFavorited ? .red : .gray)
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
                .padding()
            }
        }
        .padding(.vertical, 5)
    }
}

struct DrinkDetailPage: View {
    @StateObject private var viewModel: DrinkDetailViewModel

    init(drink: Drink) {
        _viewModel = StateObject(wrappedValue: DrinkDetailViewModel(drink: drink))
    }

    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading) {
                    if let urlString = viewModel.drink.thumbnailURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    Text(viewModel.drink.name)
                        .font(.largeTitle)
                        .padding(.vertical)

                    Text("Ingredients:")
                        .font(.headline)

                    if viewModel.drink.ingredients.isEmpty {
                        ProgressView("Loading ingredients...")
                            .padding(.top)
                    } else {
                        ForEach(viewModel.drink.ingredients, id: \.self) { ingredient in
                            Text("- \(ingredient)")
                        }
                    }

                    if let instructions = viewModel.drink.strInstructions, !instructions.isEmpty {
                        Text("Instructions:")
                            .font(.headline)
                            .padding(.top)
                        Text(instructions)
                            .padding(.top, 5)
                    } else {
                        Text("Loading instructions...")
                            .padding(.top)
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle(viewModel.drink.name)
            }
        }
    }
}
