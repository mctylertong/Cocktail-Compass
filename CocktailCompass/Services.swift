//
//  Services.swift
//  CocktailCompass
//
//  Created by McTyler Tong on 10/22/24.
//

import Foundation
import Combine
import CoreData

class DrinkAPIService {
    static func fetchDrinks(query: String) -> AnyPublisher<[Drink], Error> {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=\(encodedQuery)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: DrinkResponse.self, decoder: JSONDecoder())
            .map { $0.drinks ?? [] }
            .eraseToAnyPublisher()
    }

    static func fetchDrinksByIngredient(_ ingredient: String) -> AnyPublisher<[Drink], Error> {
        let encodedIngredient = ingredient.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?i=\(encodedIngredient)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: DrinkResponse.self, decoder: JSONDecoder())
            .map { $0.drinks ?? [] }
            .eraseToAnyPublisher()
    }
    
    static func fetchDrinkDetails(by id: String) -> AnyPublisher<Drink, Error> {
        let urlString = "https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=\(id)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: DrinkResponse.self, decoder: JSONDecoder())
            .tryMap { response in
                guard let drink = response.drinks?.first else {
                    throw URLError(.badServerResponse)
                }
                return drink
            }
            .eraseToAnyPublisher()
    }
}

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = PersistenceController.shared.container
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Unresolved error \(error)")
            }
        }
    }
    
    func fetchFavoritedDrinks() -> [Drink] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<FavoritedDrink> = FavoritedDrink.fetchRequest()
        do {
            let favoritedDrinks = try context.fetch(request)
            return favoritedDrinks.map { $0.toDrink() }
        } catch {
            print("Error fetching drinks: \(error)")
            return []
        }
    }
    
    func addFavoritedDrink(_ drink: Drink) {
        let context = persistentContainer.viewContext
        let newDrink = FavoritedDrink(context: context)
        newDrink.idDrink = drink.id
        newDrink.strDrink = drink.name
        newDrink.strDrinkThumb = drink.thumbnailURL
        newDrink.strInstructions = drink.strInstructions
        saveContext()
    }

    func deleteFavoritedDrink(_ drink: Drink) {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<FavoritedDrink> = FavoritedDrink.fetchRequest()
        request.predicate = NSPredicate(format: "idDrink == %@", drink.id)
        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            saveContext()
        } catch {
            print("Error deleting drink: \(error)")
        }
    }
}

extension Drink {
    init(favoritedDrink: FavoritedDrink) {
        self.idDrink = favoritedDrink.idDrink ?? ""
        self.strDrink = favoritedDrink.strDrink ?? ""
        self.strDrinkThumb = favoritedDrink.strDrinkThumb
        self.strInstructions = favoritedDrink.strInstructions
        self.strIngredient1 = nil
        self.strIngredient2 = nil
        self.strIngredient3 = nil
        self.strIngredient4 = nil
        self.strIngredient5 = nil
        self.strIngredient6 = nil
        self.strIngredient7 = nil
        self.strIngredient8 = nil
        self.strIngredient9 = nil
        self.strIngredient10 = nil
        self.strIngredient11 = nil
        self.strIngredient12 = nil
        self.strIngredient13 = nil
        self.strIngredient14 = nil
        self.strIngredient15 = nil
        self.strMeasure1 = nil
        self.strMeasure2 = nil
        self.strMeasure3 = nil
        self.strMeasure4 = nil
        self.strMeasure5 = nil
        self.strMeasure6 = nil
        self.strMeasure7 = nil
        self.strMeasure8 = nil
        self.strMeasure9 = nil
        self.strMeasure10 = nil
        self.strMeasure11 = nil
        self.strMeasure12 = nil
        self.strMeasure13 = nil
        self.strMeasure14 = nil
        self.strMeasure15 = nil
    }
}

extension FavoritedDrink {
    func toDrink() -> Drink {
        return Drink(favoritedDrink: self)
    }
}

