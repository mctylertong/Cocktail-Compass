//
//  CocktailCompassApp.swift
//  CocktailCompass
//
//  Created by McTyler Tong on 10/22/24.
//

import SwiftUI

@main
struct CocktailCompassApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var favoritesViewModel = FavoritesViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(favoritesViewModel)
        }
    }
}
