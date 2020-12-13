//
//  RecipesPresenter.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 13.12.2020.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import Foundation

protocol IRecipesPresenter {
    
    init(model: IRecipesModel)
    
    var recipes: [Recipe] { get }
    var thumbnailsData: [Int: Data] { get }
    
}

final class RecipesPresenter: IRecipesPresenter {
    
    // MARK: - Properties
    
    weak var view: IRecipesView?
    
    var recipes: [Recipe] {
        return model.getRecipes()
    }
    
    var thumbnailsData: [Int: Data] {
        return model.thumbnailsData
    }
    
    // MARK: - Private properties
    
    private let model: IRecipesModel
    
    // MARK: - Life cycle
    
    init(model: IRecipesModel) {
        self.model = model
        model.addObserver(self)
    }
    
}

extension RecipesPresenter: IRecipesModelObserver {
    
    func recipesUpdated() {
        view?.reloadContent()
    }
    
}
