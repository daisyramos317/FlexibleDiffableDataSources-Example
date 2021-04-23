//
//  TableViewSection.swift
//  FlexibleDiffableDataSources
//
//  Created by Daisy Ramos on 4/18/21.
//

enum TableViewSection {

    case main

    var headerTitle: String {
        switch self {
            case .main:
            return "Main Section"
        }
    }
}

enum Data: Hashable {

    case main

}
