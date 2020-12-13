//
//  RecipesViewController.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 13.12.20.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import UIKit

protocol IRecipesView: AnyObject {
    
    init(presenter: IRecipesPresenter)
    
    func reloadContent()
    
}

final class RecipesViewController: UIViewController, IRecipesView {
    
    private enum Constants {
        static let rowHeight: CGFloat = 100
        static let animationDuration: TimeInterval = 0.25
    }
    
    // MARK: - Private properties
    
    private let presenter: IRecipesPresenter
    
    // MARK: - Views
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = Constants.rowHeight
        tableView.register(RecipeTableViewCell.self, forCellReuseIdentifier: RecipeTableViewCell.className)
        tableView.tableFooterView = UIView()
        tableView.alpha = 0
        return tableView
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .large)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        }
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    // MARK: - Life cycle
    
    init(presenter: IRecipesPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новогодние рецепты"
        configureSubviews()
        updateActivityIndicatorVisibility()
    }
    
    // MARK: - Methods
    
    func reloadContent() {
        updateActivityIndicatorVisibility()
        tableView.reloadData()
    }
    
    // MARK: - Private methods
    
    private func updateActivityIndicatorVisibility() {
        if !presenter.recipes.isEmpty {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.tableView.alpha = 1
                self.activityIndicator.alpha = 0
            } completion: { _ in
                self.activityIndicator.stopAnimating()
            }
        }
    }

}

extension RecipesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension RecipesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeTableViewCell.className, for: indexPath)
        guard let recipeTableViewCell = cell as? RecipeTableViewCell else { return cell }
        let recipe = presenter.recipes[indexPath.row]
        let thumbnailData = presenter.thumbnailsData[recipe.id]
        var thumbnail: UIImage?
        if let data = thumbnailData {
            thumbnail = UIImage(data: data)
        }
        recipeTableViewCell.configure(image: thumbnail, title: recipe.name, description: recipe.description)
        return recipeTableViewCell
    }
    
}

private extension RecipesViewController {
    
    // MARK: - Subviews configuration
    
    func configureSubviews() {
        addSubviews()
        configureTableView()
        configureActivityIndicator()
    }
    
    func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
    }
    
    func configureTableView() {
        tableView.pin(.leading, to: .leading, of: view)
        tableView.pin(.top, to: .top, of: view)
        tableView.pin(.trailing, to: .trailing, of: view)
        tableView.pin(.bottom, to: .bottom, of: view)
    }
    
    func configureActivityIndicator() {
        activityIndicator.pin(.centerX, to: .centerX, of: view)
        activityIndicator.pin(.centerY, to: .centerY, of: view)
    }
    
}
