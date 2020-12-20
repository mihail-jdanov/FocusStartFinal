//
//  RecipeModel.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 20.12.2020.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import Foundation

protocol IRecipeModel {
    
    init(_ recipe: Recipe)
    
    var recipe: Recipe { get }
    var recipeImageData: Data? { get }
    
    func addObserver(_ observer: IRecipeModelObserver)
    func removeObserver(_ observer: IRecipeModelObserver)
    
}

protocol IRecipeModelObserver: AnyObject {
    
    func recipeModelUpdated()
    
}

final class RecipeModel: IRecipeModel {
    
    // MARK: - Properties
    
    let recipe: Recipe
    
    var recipeImageData: Data?
    
    // MARK: - Private properties
    
    private let observers = NSHashTable<AnyObject>.weakObjects()
    
    // MARK: - Life cycle
    
    init(_ recipe: Recipe) {
        self.recipe = recipe
        loadRecipeImageData()
    }
    
    // MARK: - Methods
    
    func addObserver(_ observer: IRecipeModelObserver) {
        observers.add(observer)
    }
    
    func removeObserver(_ observer: IRecipeModelObserver) {
        observers.remove(observer)
    }
    
    // MARK: - Private methods
    
    private func loadRecipeImageData() {
        DispatchQueue.global().async {
            self.recipeImageData = try? Data(contentsOf: self.recipe.imageUrl)
            self.notifyObserversModelUpdated()
        }
    }
    
    private func notifyObserversModelUpdated() {
        DispatchQueue.main.async {
            self.observers.allObjects.forEach { object in
                (object as? IRecipeModelObserver)?.recipeModelUpdated()
            }
        }
    }
    
}
