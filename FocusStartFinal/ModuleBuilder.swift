//
//  ModuleBuilder.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 13.12.2020.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import UIKit

final class ModuleBuilder {
    
    static func createRecipesModule() -> UIViewController {
        let model = RecipesModel.shared
        let presenter = RecipesPresenter(model: model)
        let viewController = RecipesViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
    
}
