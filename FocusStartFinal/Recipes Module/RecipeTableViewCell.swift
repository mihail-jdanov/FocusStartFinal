//
//  RecipeTableViewCell.swift
//  FocusStartFinal
//
//  Created by Михаил Жданов on 13.12.2020.
//  Copyright © 2020 Михаил Жданов. All rights reserved.
//

import UIKit

final class RecipeTableViewCell: UITableViewCell {
    
    private enum Constants {
        static let smallSpacing: CGFloat = 8
        static let largeSpacing: CGFloat = 16
        static let animationDuration: TimeInterval = 0.25
    }
    
    // MARK: - Views
    
    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.numberOfLines = 0
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    // MARK: - Life cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func configure(image: UIImage?, title: String, description: String) {
        previewImageView.image = image
        titleLabel.text = title
        descriptionLabel.text = description
        if let _ = image {
            activityIndicator.stopAnimating()
            UIView.animate(withDuration: Constants.animationDuration) {
                self.previewImageView.alpha = 1
            }
        }
    }
    
}

private extension RecipeTableViewCell {
    
    // MARK: - Subviews configuration
    
    func configureSubviews() {
        addSubviews()
        configurePreviewImageView()
        configureTitleLabel()
        configureDescriptionLabel()
        configureActivityIndicator()
    }
    
    func addSubviews() {
        contentView.addSubview(previewImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(activityIndicator)
    }
    
    func configurePreviewImageView() {
        previewImageView.pin(.leading, to: .leading, of: contentView)
        previewImageView.pin(.top, to: .top, of: contentView)
        previewImageView.pin(.bottom, to: .bottom, of: contentView)
        previewImageView.pin(.width, to: .height, of: previewImageView, multiplier: 4 / 3)
    }
    
    func configureTitleLabel() {
        titleLabel.pin(.leading, to: .trailing, of: previewImageView, constant: Constants.largeSpacing)
        titleLabel.pin(.top, to: .top, of: contentView, constant: Constants.smallSpacing)
        titleLabel.pin(.trailing, to: .trailing, of: contentView, constant: -Constants.largeSpacing)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
    func configureDescriptionLabel() {
        descriptionLabel.pin(.leading, to: .trailing, of: previewImageView, constant: Constants.largeSpacing)
        descriptionLabel.pin(.top, to: .bottom, of: titleLabel, constant: Constants.smallSpacing)
        descriptionLabel.pin(.trailing, to: .trailing, of: contentView, constant: -Constants.largeSpacing)
        descriptionLabel.pin(.bottom, to: .bottom, of: contentView, constant: -Constants.smallSpacing)
        descriptionLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    func configureActivityIndicator() {
        activityIndicator.pin(.centerX, to: .centerX, of: previewImageView)
        activityIndicator.pin(.centerY, to: .centerY, of: previewImageView)
    }
    
}
