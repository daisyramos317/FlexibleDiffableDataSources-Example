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

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "CompanyLogoCell", bundle: nil), forCellWithReuseIdentifier: "CompanyLogoCell")
        
        tableView.dataSource = self
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

                        var deletedIndexPaths = [IndexPath]()
                        var insertedIndexPaths = [IndexPath]()
                        let diff = companies.difference(from: self.companies)

                        for change in diff {
                            switch change {
                            case let .remove(offset, _, _):
                                deletedIndexPaths.append(IndexPath(row: offset, section: 0))
                            case let .insert(offset, _, _):
                                insertedIndexPaths.append(IndexPath(row: offset, section: 0))
                            }
                        }

                        self.companies = companies

                        self.tableView.performBatchUpdates({
                            self.tableView.deleteRows(at: deletedIndexPaths, with: .fade)
                            self.tableView.insertRows(at: insertedIndexPaths, with: .left)
                        })
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

extension CompanySearchResultViewController: UITableViewDataSource {
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let company = companies[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: "companyCell")
        cell.textLabel?.text = company.name

        return cell
    }
}
