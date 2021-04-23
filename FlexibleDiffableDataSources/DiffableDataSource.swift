import UIKit

/// An object that conforms to `UITableViewDataSource`and `UICollectionViewDataSource` that wraps `UITableViewDiffableDataSource` and `UICollectionViewDiffableDataSource`.
final class DiffableDataSource<Section: Hashable, Item: Hashable>: NSObject, UITableViewDataSource, UICollectionViewDataSource {

    /// The type of collection this diffable data source will be used with.
    enum CollectionType {

        /// When using with a `UICollectionView`.
        /// - Parameter collectionView: The `UICollectionView` that this data source is providing data for.
        /// - Parameter collectionViewCellConfiguration: A closure for creating and configuring a cell with a model.
        /// - Parameter collectionViewSupplementaryViewProvider: An optional closure for creating and configuring supplementary views.
        case collectionView(_ collectionView: UICollectionView, collectionViewCellConfiguration: UICollectionViewDiffableDataSource<Section, Item>.CellProvider, collectionViewSupplementaryViewProvider: UICollectionViewDiffableDataSource<Section, Item>.SupplementaryViewProvider?)

        /// When using with a `UITableView`.
        /// - Parameter tableView: The `UITableView` that this data source is providing data for.
        /// - Parameter tableViewCellConfiguration: A closure for creating and configuring a cell with a model.
        case tableView(_ tableView: UITableView, tableViewCellConfiguration: UITableViewDiffableDataSource<Section, Item>.CellProvider)
    }


    /// A closure for creating and configuring an item cell with a model.
    /// - Parameters:
    ///   - tableView: The collection view the cell will be configured for.
    ///   - indexPath: The index path of the cell.
    ///   - item: The items to display in the your videos collection.
    typealias CellConfiguration = (_ tableView: UITableView, _ indexPath: IndexPath, _ item: Item) -> UITableViewCell

    private var collectionViewDataSource: UICollectionViewDiffableDataSource<Section, Item>?
    private var tableViewDataSource: UITableViewDiffableDataSource<Section, Item>?
    private let collectionType: CollectionType

    /// Creates a `DiffableDataSource`.
    /// - Parameter collectionType: The type of collection this diffable data source will be used with.
    init(collectionType: CollectionType) {
        self.collectionType = collectionType

        switch collectionType {
        case let .collectionView(collectionView, collectionViewCellConfiguration, collectionViewSupplementaryViewProvider):
            let dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: collectionViewCellConfiguration)
            dataSource.supplementaryViewProvider = collectionViewSupplementaryViewProvider
            self.collectionViewDataSource = dataSource
        case let .tableView(tableView, tableViewCellConfiguration):
            self.tableViewDataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView, cellProvider: tableViewCellConfiguration)
        }
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionViewDataSource?.numberOfSections(in: collectionView) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionViewDataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionViewDataSource?.collectionView(collectionView, cellForItemAt: indexPath) ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        collectionViewDataSource?.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath) ?? UICollectionReusableView()
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        tableViewDataSource?.numberOfSections(in: tableView) ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewDataSource?.tableView(tableView, numberOfRowsInSection: section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableViewDataSource?.tableView(tableView, cellForRowAt: indexPath) ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let section = self.section(at: section) as? TableViewSection {
            return section.headerTitle
        }

        return nil
    }

    // MARK: - DiffableDataSource

    /// Updates the UI to reflect the state of the data in the specified snapshot, optionally animating the UI changes and executing a completion handler.
    /// - Parameters:
    ///   - snapshot: The snapshot reflecting the new state of the data.
    ///   - animatingDifferences: If true, the diffable data source computes the difference between the table view’s current state and the new state in the snapshot, which is an O(n) operation, where n is the number of items in the snapshot. The differences in the UI between the current state and new state are animated. If false, the table view UI is set to the new state without any animations, with no additional overhead for computing a diff. Any ongoing item animations are interrupted and the table view’s content is reloaded immediately.
    ///   - completion: A closure to be executed when the animations are complete. This closure has no return value and takes no parameters.
    func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        switch collectionType {
        case .collectionView:
            collectionViewDataSource?.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
        case .tableView:
            tableViewDataSource?.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
        }
    }

    /// Provides a `Section` for the given section index.
    /// - Parameter index: The index of the section.
    func section(at index: Int) -> Section? {
        switch collectionType {
        case .collectionView:
            guard let currentSnapshot = collectionViewDataSource?.snapshot(), index < currentSnapshot.sectionIdentifiers.count, index >= 0 else {
                return nil
            }

            return currentSnapshot.sectionIdentifiers[index]
        case .tableView:
            guard let currentSnapshot = tableViewDataSource?.snapshot(), index < currentSnapshot.sectionIdentifiers.count, index >= 0 else {
                return nil
            }

            return currentSnapshot.sectionIdentifiers[index]
        }
    }

    /// Provides an `Item` for the given `IndexPath`.
    /// - Parameter indexPath: The `IndexPath` of the desired item.
    subscript(_ indexPath: IndexPath) -> Item? {
        return item(at: indexPath)
    }

    /// Provides an `Item` for the given `IndexPath`.
    /// - Parameter indexPath: The `IndexPath` of the desired item.
    func item(at indexPath: IndexPath) -> Item? {
        switch collectionType {
        case .collectionView:
            return collectionViewDataSource?.itemIdentifier(for: indexPath)
        case .tableView:
            return tableViewDataSource?.itemIdentifier(for: indexPath)
        }
    }
}

