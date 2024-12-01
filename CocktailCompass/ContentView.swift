//
//  ContentView.swift
//  CocktailCompass
//
//  Created by McTyler Tong on 10/22/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var searchNavViewID = UUID()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomePage()
            }
            .id(searchNavViewID)
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(0)

            NavigationView {
                FavoritedDrinksPage()
            }
            .tabItem {
                Image(systemName: "heart")
                Text("Saved")
            }
            .tag(1)

            NavigationView {
                MapPage()
            }
            .tabItem {
                Image(systemName: "map")
                Text("Map")
            }
            .tag(2)
        }
        .onChange(of: selectedTab) { newValue in
            if newValue == 0 {
                searchNavViewID = UUID()
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
