//
//  Networking.swift
//  FlexibleDiffableDataSources
//
//  Created by Daisy Ramos on 4/18/21.
//

import Foundation
import Combine

struct Networking {
    private let session = URLSession.shared

    private struct Response<T> {
        let value: T
        let response: URLResponse
    }

    private func perform<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return session
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func perform<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        return perform(request)
            .map(\.value)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
