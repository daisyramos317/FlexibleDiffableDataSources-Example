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
                        self.companies = companies
                        self.tableView.reloadData()
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
