//
//  FavoritesViewController.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 21.12.2020.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import UIKit

protocol IFavoritesView: AnyObject {
    
    init(presenter: IFavoritesPresenter)
    
    func reloadContent()
    
}

final class FavoritesViewController: UIViewController, IFavoritesView {
    
    private enum Constants {
        static let rowHeight: CGFloat = 100
        static let spacing: CGFloat = 16
        static let emptyLabelAlpha: CGFloat = 0.5
        static let animationDuration: TimeInterval = 0.25
    }
    
    // MARK: - Private properties
    
    private let presenter: IFavoritesPresenter
    
    // MARK: - Views
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = Constants.rowHeight
        tableView.register(RecipeTableViewCell.self, forCellReuseIdentifier: RecipeTableViewCell.className)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
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
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .callout)
        label.textAlignment = .center
        label.text = "Вы ещё не добавили ни одного рецепта :("
        label.alpha = 0
        return label
    }()
    
    private lazy var closeBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            image: nil,
            style: .plain,
            target: self,
            action: #selector(closeButtonAction)
        )
        barButtonItem.title = "Закрыть"
        return barButtonItem
    }()
    
    // MARK: - Life cycle
    
    init(presenter: IFavoritesPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Избранные рецепты"
        view.backgroundColor = .defaultViewColor
        configureSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadContent()
    }
    
    // MARK: - Methods
    
    func reloadContent() {
        updateIndicatorAndEmptyLabelVisibility()
        tableView.reloadData()
    }
    
    // MARK: - Private methods
    
    private func updateIndicatorAndEmptyLabelVisibility() {
        guard presenter.isRecipesFetchCompleted else { return }
        let labelAlpha = presenter.favoriteRecipes.isEmpty ? Constants.emptyLabelAlpha : 0
        UIView.animate(withDuration: Constants.animationDuration) {
            self.activityIndicator.alpha = 0
            self.emptyLabel.alpha = labelAlpha
        } completion: { _ in
            self.activityIndicator.stopAnimating()
        }
    }
    
    @objc
    private func closeButtonAction() {
        dismiss(animated: true, completion: nil)
    }

}

extension FavoritesViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = presenter.favoriteRecipes[indexPath.row]
        let nextModule = ModuleBuilder.createRecipeModule(with: recipe)
        navigationController?.pushViewController(nextModule, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension FavoritesViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.favoriteRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeTableViewCell.className, for: indexPath)
        guard let recipeTableViewCell = cell as? RecipeTableViewCell else { return cell }
        let recipe = presenter.favoriteRecipes[indexPath.row]
        var thumbnail: UIImage?
        if let data = recipe.thumbnailData {
            thumbnail = UIImage(data: data)
        }
        recipeTableViewCell.configure(image: thumbnail, title: recipe.name, description: recipe.description)
        return recipeTableViewCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        presenter.removeFavoriteRecipe(atRow: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        updateIndicatorAndEmptyLabelVisibility()
    }
    
}

private extension FavoritesViewController {
    
    // MARK: - Subviews configuration
    
    func configureSubviews() {
        addSubviews()
        configureTableView()
        configureActivityIndicator()
        configureEmptyLabel()
        navigationItem.leftBarButtonItem = closeBarButtonItem
    }
    
    func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyLabel)
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
    
    func configureEmptyLabel() {
        emptyLabel.pin(.leading, to: .leading, of: view, constant: Constants.spacing)
        emptyLabel.pin(.trailing, to: .trailing, of: view, constant: -Constants.spacing)
        emptyLabel.pin(.centerY, to: .centerY, of: view)
    }
    
}
