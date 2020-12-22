//
//  RecipesModel.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 13.12.2020.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import Foundation

protocol IRecipesModel {
    
    var isFetchCompleted: Bool { get }
    
    func getRecipes() -> [Recipe]
    func addObserver(_ observer: IRecipesModelObserver)
    func removeObserver(_ observer: IRecipesModelObserver)
    
}

protocol IRecipesModelObserver: AnyObject {
    
    func recipesModelUpdated()
    
}

final class RecipesModel: IRecipesModel {
        
    // MARK: - Singleton instance
    
    static let shared = RecipesModel()
    
    // MARK: - Properties
    
    private(set) var isFetchCompleted = false
    
    // MARK: - Private properties
    
    private let recipesUrl = URL(string: "http://m90595w5.bget.ru/recipes.json")
    private let observers = NSHashTable<AnyObject>.weakObjects()
    private let fetchRetryinterval: TimeInterval = 3
    
    private var isFetchInProgress = false
    
    private var urlSession: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["User-Agent": "Mozilla/5.0"]
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }
    
    private var recipes: [Recipe] = [] {
        didSet {
            notifyObserversModelUpdated()
            loadThumbnails()
        }
    }
    
    // MARK: - Life cycle
    
    private init() {}
    
    // MARK: - Methods
    
    func addObserver(_ observer: IRecipesModelObserver) {
        observers.add(observer)
    }
    
    func removeObserver(_ observer: IRecipesModelObserver) {
        observers.remove(observer)
    }
    
    func getRecipes() -> [Recipe] {
        if !isFetchCompleted {
            fetchRecipes()
        }
        return recipes
    }
    
    // MARK: - Private methods
    
    private func fetchRecipes() {
        guard !isFetchInProgress else { return }
        guard let url = recipesUrl else {
            print("Invalid recipes URL")
            return
        }
        isFetchInProgress = true
        urlSession.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching recipes: " + error.localizedDescription)
            }
            if let response = response as? HTTPURLResponse, !(response.statusCode >= 200 && response.statusCode < 300) {
                print("Error fetching recipes: status code \(response.statusCode)")
            }
            if let data = data {
                do {
                    let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                    self.recipes = recipes
                    self.isFetchCompleted = true
                } catch {
                    print("Error fetching recipes: " + error.localizedDescription)
                }
            } else {
                print("Error fetching recipes: no data")
            }
            self.isFetchInProgress = false
            self.retryFetchRecipesIfNeeded()
        }.resume()
    }
    
    private func retryFetchRecipesIfNeeded() {
        guard recipes.isEmpty else { return }
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + fetchRetryinterval) {
            self.fetchRecipes()
        }
    }
    
    private func loadThumbnails() {
        DispatchQueue.global(qos: .background).async {
            for recipe in self.recipes {
                guard recipe.thumbnailData == nil else { continue }
                recipe.thumbnailData = try? Data(contentsOf: recipe.thumbnailUrl)
            }
            self.notifyObserversModelUpdated()
        }
    }
    
    private func notifyObserversModelUpdated() {
        DispatchQueue.main.async {
            self.observers.allObjects.forEach { object in
                (object as? IRecipesModelObserver)?.recipesModelUpdated()
            }
        }
    }
    
}
