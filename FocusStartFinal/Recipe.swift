//
//  Recipe.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 13.12.2020.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import Foundation

class Recipe: Codable {
    
    let id: Int
    let name: String
    let description: String
    let thumbnailUrl: URL
    let imageUrl: URL
    let cookingTime: Int
    let ingredients: [String]
    let steps: [String]
    
    var thumbnailData: Data?
    
    var isFavorite: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "FavoriteRecipe\(id)")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "FavoriteRecipe\(id)")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case thumbnailUrl = "thumbnail_url"
        case imageUrl = "image_url"
        case cookingTime = "cooking_time"
        case ingredients
        case steps
    }
    
}
