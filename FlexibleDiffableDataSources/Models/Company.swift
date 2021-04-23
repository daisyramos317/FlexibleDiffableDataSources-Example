//
//  Company.swift
//  FlexibleDiffableDataSources
//
//  Created by Daisy Ramos on 4/18/21.
//

import Foundation

/// Represents a company.
struct Company: Codable, Hashable {
    
    /// A url for the company logo if one exists.
    let logo: URL

    /// The name of the company.
    let name: String
}
