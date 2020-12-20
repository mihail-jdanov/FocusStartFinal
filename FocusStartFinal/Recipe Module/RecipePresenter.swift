//
//  RecipePresenter.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 20.12.2020.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import Foundation

protocol IRecipePresenter {
    
    init(model: IRecipeModel)
    
    var recipe: Recipe { get }
    var recipeImageData: Data? { get }
    var humanReadableCookingTime: String { get }
    
    func addToFavorites()
    
}

final class RecipePresenter: IRecipePresenter {
    
    // MARK: - Properties
    
    weak var view: IRecipeView?
    
    var recipe: Recipe {
        return model.recipe
    }
    
    var recipeImageData: Data? {
        return model.recipeImageData
    }
    
    var humanReadableCookingTime: String {
        let time = recipe.cookingTime
        let minutesPerHour = 60
        let hours = time / minutesPerHour
        let minutes = time % minutesPerHour
        if hours == 0 {
            return "\(minutes) мин"
        }
        return "\(hours) ч \(minutes) мин"
    }
    
    // MARK: - Private properties
    
    private let model: IRecipeModel
    
    // MARK: - Life cycle
    
    init(model: IRecipeModel) {
        self.model = model
        model.addObserver(self)
    }
    
    // MARK: - Methods
    
    func addToFavorites() {
        recipe.isFavorite = !recipe.isFavorite
        view?.updateFavoritesButton()
    }
    
}

extension RecipePresenter: IRecipeModelObserver {
    
    func recipeModelUpdated() {
        view?.updateImage()
    }
    
}
