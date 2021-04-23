//
//  CompanySearchResultViewController.swift
//  FlexibleDiffableDataSources
//
//  Created by Daisy Ramos on 4/19/21.
//

import UIKit
import Combine

final class CompanySearchResultViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var collectionView: UICollectionView!

    private let networking = Networking()
    private var cancellables = Set<AnyCancellable>()
    private let base = "https://autocomplete.clearbit.com/v1/companies/suggest"
    private var companies = [Company]()

    enum Section {
        case main
    }

    private lazy var tableViewDataSource = UITableViewDiffableDataSource<Section, Company>(tableView: tableView) { (tableView, indexPath, model) -> UITableViewCell? in
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "companyCell")
        cell.textLabel?.text = model.name
        return cell
    }

    private lazy var collectionViewDataSource = UICollectionViewDiffableDataSource<Section, Company>(collectionView: collectionView) {
        (collectionView, indexPath, model) -> UICollectionViewCell? in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompanyLogoCell", for: indexPath) as? CompanyLogoCell
        cell?.viewModel = CompanyLogoCell.ViewModel(imageURL: model.logo)
        return cell
    }

    private let compositionalLayout: UICollectionViewCompositionalLayout = {
        let fraction: CGFloat = 1.0 / 3.0

        // Item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalWidth(fraction))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 100, leading: 2.5, bottom: 0, trailing: 2.5)
        section.orthogonalScrollingBehavior = .continuous
        section.visibleItemsInvalidationHandler = { (items, offset, environment) in
            items.forEach { item in
                let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
                let minScale: CGFloat = 0.7
                let maxScale: CGFloat = 1.1
                let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }

        return UICollectionViewCompositionalLayout(section: section)
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "CompanyLogoCell", bundle: nil), forCellWithReuseIdentifier: "CompanyLogoCell")
        
        tableView.dataSource = tableViewDataSource
        collectionView.dataSource = collectionViewDataSource
        collectionView.collectionViewLayout = compositionalLayout
    }

    // MARK:- CompanySearchResultViewController

    @IBAction private func updateSearch(_ sender: UITextField) {
        guard let searchText = sender.text, !searchText.isEmpty else {
            return
        }
        let companies = updateSearch(searchText: sender.text ?? "")
        let result = companies.map { $0 }

        result.sink(receiveCompletion: { _ in },
                    receiveValue: { [weak self] companies in
                        guard let self = self else {
                            return
                        }

                        self.updateCompanies(companies: companies)
                        print(companies)
                    })
            .store(in: &cancellables)

    }
}

extension CompanySearchResultViewController {

    private func updateSearch(searchText: String) -> AnyPublisher<[Company], Error> {
        var url = URLComponents(string: base)!
        url.queryItems = [
            URLQueryItem(name: "query", value: searchText)
        ]
        return networking.perform(URLRequest(url: url.url!))
    }
}

extension CompanySearchResultViewController {

    private func updateCompanies(companies: [Company]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Company>()
        snapshot.appendSections([.main])
        snapshot.appendItems(companies)
        tableViewDataSource.apply(snapshot, animatingDifferences: true)
        collectionViewDataSource.apply(snapshot, animatingDifferences: true)
    }
}
