//
//  CompanyLogoCell.swift
//  FlexibleDiffableDataSources
//
//  Created by Daisy Ramos on 4/20/21.
//

import UIKit
import Kingfisher

/// Represents a company logo.
final class CompanyLogoCell: UICollectionViewCell {

    /// Encapsulates the properties required to display the contents of the cell.
    struct ViewModel {

        /// The URL of the image displayed in the cell.
        let imageURL: URL
    }

    @IBOutlet private weak var imageView: UIImageView!

    /// The cell’s view model. Setting the view model updates the display of the cell contents.
    var viewModel: ViewModel? {
        didSet {
            imageView.kf.cancelDownloadTask()
            imageView.kf.setImage(with: viewModel?.imageURL)
        }
    }
}
