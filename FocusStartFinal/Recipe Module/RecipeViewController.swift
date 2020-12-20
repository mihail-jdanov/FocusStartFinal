//
//  RecipeViewController.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 20.12.2020.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import UIKit

protocol IRecipeView: AnyObject {
    
    init(presenter: IRecipePresenter)
    
    func updateImage()
    func updateFavoritesButton()
    
}

final class RecipeViewController: UIViewController, IRecipeView {
    
    private enum Constants {
        static let headerImageViewAspectRatio: CGFloat = 16 / 9
        static let smallSpacing: CGFloat = 16
        static let largeSpacing: CGFloat = 32
        static let tableViewRowHeight: CGFloat = 50
        static let separatorColor: UIColor = .gray
        static let separatorHeight: CGFloat = 1
        static let animationDuration: TimeInterval = 0.25
        static let animationDelay: TimeInterval = 0.15
    }
    
    // MARK: - Private properties
    
    private let presenter: IRecipePresenter
    
    private var favoritesImage: UIImage? {
        return presenter.recipe.isFavorite ? UIImage(named: "FavoriteOn") : UIImage(named: "FavoriteOff")
    }
    
    // MARK: - Views
    
    private let scrollView = UIScrollView()
    private let scrollableContentView = UIView()
    
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
    
    private lazy var headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        if let data = presenter.recipe.thumbnailData {
            imageView.image = UIImage(data: data)
            activityIndicator.stopAnimating()
        }
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .callout)
        label.textAlignment = .justified
        label.text = presenter.recipe.description
        return label
    }()
    
    private lazy var cookingTimeLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = "Время приготовления: " + presenter.humanReadableCookingTime
        return label
    }()
    
    private let ingredientsLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = "Ингредиенты:"
        return label
    }()
    
    private lazy var ingredientsTableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.rowHeight = Constants.tableViewRowHeight
        tableView.dataSource = self
        tableView.sectionHeaderHeight = Constants.separatorHeight
        return tableView
    }()
    
    private let stepsTitleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = "Пошаговый рецепт приготовления:"
        return label
    }()
    
    private var stepsLabels: [UILabel] = []
    
    private lazy var addToFavoritesBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            image: favoritesImage,
            style: .plain,
            target: self,
            action: #selector(addToFavoritesButtonAction)
        )
        return barButtonItem
    }()
    
    // MARK: - Life cycle
    
    init(presenter: IRecipePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .defaultViewColor
        title = presenter.recipe.name
        configureSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAnimation()
    }
    
    // MARK: - Methods
    
    func updateImage() {
        if let data = presenter.recipeImageData {
            headerImageView.image = UIImage(data: data)
            activityIndicator.stopAnimating()
        }
    }
    
    func updateFavoritesButton() {
        addToFavoritesBarButtonItem.image = favoritesImage
    }
    
    // MARK: - Private methods
    
    private func startAnimation() {
        var views = [descriptionLabel, cookingTimeLabel, ingredientsLabel, ingredientsTableView, stepsTitleLabel]
        views.append(contentsOf: stepsLabels)
        views.forEach { $0.alpha = 0 }
        let millisecondsPerSecond = 1000000
        DispatchQueue.global().async {
            views.forEach { view in
                usleep(useconds_t(Constants.animationDelay * Double(millisecondsPerSecond)))
                DispatchQueue.main.async {
                    UIView.animate(withDuration: Constants.animationDuration) {
                        view.alpha = 1
                    }
                }
            }
        }
    }
    
    @objc
    private func addToFavoritesButtonAction() {
        presenter.addToFavorites()
    }

}

extension RecipeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let separatorView = UIView()
        separatorView.backgroundColor = Constants.separatorColor
        return separatorView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
}

extension RecipeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case ingredientsTableView:
            return presenter.recipe.ingredients.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case ingredientsTableView:
            let cell = UITableViewCell()
            cell.textLabel?.numberOfLines = 2
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            cell.textLabel?.text = presenter.recipe.ingredients[indexPath.row]
            return cell
        default:
            return UITableViewCell()
        }
    }
    
}

private extension RecipeViewController {
    
    // MARK: - Subviews configuration
    
    func configureSubviews() {
        addSubviews()
        configureScrollView()
        configureScrollableContentView()
        configureHeaderImageView()
        configureActivityIndicator()
        configureDescriptionLabel()
        configureCookingTimeLabel()
        configureIngredientsLabel()
        configureIngredientsTableView()
        configureStepsTitleLabel()
        configureStepsLabels()
        navigationItem.rightBarButtonItem = addToFavoritesBarButtonItem
    }
    
    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollableContentView)
        scrollableContentView.addSubview(headerImageView)
        scrollableContentView.addSubview(activityIndicator)
        scrollableContentView.addSubview(descriptionLabel)
        scrollableContentView.addSubview(cookingTimeLabel)
        scrollableContentView.addSubview(ingredientsLabel)
        scrollableContentView.addSubview(ingredientsTableView)
        scrollableContentView.addSubview(stepsTitleLabel)
    }
    
    func configureScrollView() {
        scrollView.pin(.leading, to: .leading, of: view.safeAreaLayoutGuide)
        scrollView.pin(.trailing, to: .trailing, of: view.safeAreaLayoutGuide)
        scrollView.pin(.top, to: .top, of: view.safeAreaLayoutGuide)
        scrollView.pin(.bottom, to: .bottom, of: view.safeAreaLayoutGuide)
    }
    
    func configureScrollableContentView() {
        scrollableContentView.pin(.leading, to: .leading, of: scrollView)
        scrollableContentView.pin(.trailing, to: .trailing, of: scrollView)
        scrollableContentView.pin(.top, to: .top, of: scrollView)
        scrollableContentView.pin(.bottom, to: .bottom, of: scrollView)
        scrollableContentView.pin(.width, to: .width, of: scrollView)
    }
    
    func configureHeaderImageView() {
        headerImageView.pin(.leading, to: .leading, of: scrollableContentView)
        headerImageView.pin(.trailing, to: .trailing, of: scrollableContentView)
        headerImageView.pin(.top, to: .top, of: scrollableContentView)
        headerImageView.pin(.width, to: .height, of: headerImageView, multiplier: Constants.headerImageViewAspectRatio)
    }
    
    func configureActivityIndicator() {
        activityIndicator.pin(.centerX, to: .centerX, of: headerImageView)
        activityIndicator.pin(.centerY, to: .centerY, of: headerImageView)
    }
    
    func configureDescriptionLabel() {
        descriptionLabel.pin(.leading, to: .leading, of: scrollableContentView, constant: Constants.smallSpacing)
        descriptionLabel.pin(.trailing, to: .trailing, of: scrollableContentView, constant: -Constants.smallSpacing)
        descriptionLabel.pin(.top, to: .bottom, of: headerImageView, constant: Constants.smallSpacing)
    }
    
    func configureCookingTimeLabel() {
        cookingTimeLabel.pin(.leading, to: .leading, of: scrollableContentView, constant: Constants.smallSpacing)
        cookingTimeLabel.pin(.trailing, to: .trailing, of: scrollableContentView, constant: -Constants.smallSpacing)
        cookingTimeLabel.pin(.top, to: .bottom, of: descriptionLabel, constant: Constants.largeSpacing)
    }
    
    func configureIngredientsLabel() {
        ingredientsLabel.pin(.leading, to: .leading, of: scrollableContentView, constant: Constants.smallSpacing)
        ingredientsLabel.pin(.trailing, to: .trailing, of: scrollableContentView, constant: -Constants.smallSpacing)
        ingredientsLabel.pin(.top, to: .bottom, of: cookingTimeLabel, constant: Constants.largeSpacing)
    }
    
    func configureIngredientsTableView() {
        ingredientsTableView.pin(.leading, to: .leading, of: scrollableContentView)
        ingredientsTableView.pin(.trailing, to: .trailing, of: scrollableContentView)
        ingredientsTableView.pin(.top, to: .bottom, of: ingredientsLabel, constant: Constants.smallSpacing)
        let height = CGFloat(presenter.recipe.ingredients.count) * Constants.tableViewRowHeight + Constants.separatorHeight
        ingredientsTableView.pin(.height, constant: height)
    }
    
    func configureStepsTitleLabel() {
        stepsTitleLabel.pin(.leading, to: .leading, of: scrollableContentView, constant: Constants.smallSpacing)
        stepsTitleLabel.pin(.trailing, to: .trailing, of: scrollableContentView, constant: -Constants.smallSpacing)
        stepsTitleLabel.pin(.top, to: .bottom, of: ingredientsTableView, constant: Constants.largeSpacing)
    }
    
    func configureStepsLabels() {
        let steps = presenter.recipe.steps
        for index in 0 ..< steps.count {
            let titleLabel = UILabel()
            titleLabel.font = .preferredFont(forTextStyle: .headline)
            titleLabel.text = "Шаг \(index + 1)"
            guard let topLabel = index == 0 ? stepsTitleLabel : stepsLabels.last else { return }
            scrollableContentView.addSubview(titleLabel)
            titleLabel.pin(.leading, to: .leading, of: scrollableContentView, constant: Constants.smallSpacing)
            titleLabel.pin(.trailing, to: .trailing, of: scrollableContentView, constant: -Constants.smallSpacing)
            titleLabel.pin(.top, to: .bottom, of: topLabel, constant: Constants.smallSpacing)
            stepsLabels.append(titleLabel)
            let descriptionLabel = UILabel()
            descriptionLabel.font = .preferredFont(forTextStyle: .callout)
            descriptionLabel.numberOfLines = 0
            descriptionLabel.textAlignment = .justified
            descriptionLabel.text = steps[index]
            scrollableContentView.addSubview(descriptionLabel)
            descriptionLabel.pin(.leading, to: .leading, of: scrollableContentView, constant: Constants.smallSpacing)
            descriptionLabel.pin(.trailing, to: .trailing, of: scrollableContentView, constant: -Constants.smallSpacing)
            descriptionLabel.pin(.top, to: .bottom, of: titleLabel, constant: Constants.smallSpacing)
            stepsLabels.append(descriptionLabel)
        }
        guard let lastLabel = stepsLabels.last else { return }
        lastLabel.pin(.bottom, to: .bottom, of: scrollableContentView, constant: -Constants.smallSpacing)
    }
    
}
