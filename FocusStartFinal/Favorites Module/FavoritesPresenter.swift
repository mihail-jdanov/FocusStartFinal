//
//  FavoritesPresenter.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 21.12.2020.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import Foundation

protocol IFavoritesPresenter {
    
    init(model: IRecipesModel)
    
    var favoriteRecipes: [Recipe] { get }
    var isRecipesFetchCompleted: Bool { get }
    
    func removeFavoriteRecipe(atRow row: Int)
    
}

final class FavoritesPresenter: IFavoritesPresenter {
    
    // MARK: - Properties
    
    weak var view: IFavoritesView?
    
    var favoriteRecipes: [Recipe] {
        return model.getRecipes().filter { $0.isFavorite }
    }
    
    var isRecipesFetchCompleted: Bool {
        return model.isFetchCompleted
    }
    
    // MARK: - Private properties
    
    private let model: IRecipesModel
    
    // MARK: - Life cycle
    
    init(model: IRecipesModel) {
        self.model = model
        model.addObserver(self)
    }
    
    // MARK: - Methods
    
    func removeFavoriteRecipe(atRow row: Int) {
        favoriteRecipes[row].isFavorite = false
    }
    
}

extension FavoritesPresenter: IRecipesModelObserver {
    
    // MARK: - IRecipesModelObserver
    
    func recipesModelUpdated() {
        view?.reloadContent()
    }
    
}
