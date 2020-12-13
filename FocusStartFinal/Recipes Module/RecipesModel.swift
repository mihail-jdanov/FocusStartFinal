//
//  RecipesModel.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 13.12.2020.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import Foundation

protocol IRecipesModel {
    
    var thumbnailsData: [Int: Data] { get }
    
    func getRecipes() -> [Recipe]
    func addObserver(_ observer: IRecipesModelObserver)
    func removeObserver(_ observer: IRecipesModelObserver)
    
}

protocol IRecipesModelObserver: AnyObject {
    
    func recipesUpdated()
    
}

final class RecipesModel: IRecipesModel {
        
    // MARK: - Singleton instance
    
    static let shared = RecipesModel()
    
    // MARK: - Properties
    
    var thumbnailsData: [Int: Data] = [:] {
        didSet {
            notifyObserversRecipesUpdated()
        }
    }
    
    // MARK: - Private properties
    
    private let recipesUrl = URL(string: "http://m90595w5.bget.ru/recipes.json")
    private let observers = NSHashTable<AnyObject>.weakObjects()
    
    private var isFetchInProgress = false
    private var isFetchCompleted = false
    
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["User-Agent": "Mozilla/5.0"]
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }()
    
    private var recipes: [Recipe] = [] {
        didSet {
            notifyObserversRecipesUpdated()
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
        }.resume()
    }
    
    private func loadThumbnails() {
        recipes.forEach { recipe in
            guard thumbnailsData[recipe.id] == nil,
                let data = try? Data(contentsOf: recipe.thumbnailUrl) else { return }
            thumbnailsData[recipe.id] = data
        }
    }
    
    private func notifyObserversRecipesUpdated() {
        DispatchQueue.main.async {
            self.observers.allObjects.forEach { object in
                (object as? IRecipesModelObserver)?.recipesUpdated()
            }
        }
    }
    
}
