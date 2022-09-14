//
//  EditView-ViewModel.swift
//  Bucketlist
//
//  Created by Charles Bartel on 9/13/22.
//

import Combine
import Foundation
import SwiftUI

protocol AppleURLSession {
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
    func dataTaskPublisher(for url: URL) -> URLSession.DataTaskPublisher
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: AppleURLSession {}

enum NetworkError: Error {
    case invalidHTTPCode(code: Int?)
    case noDataReturned
}

extension EditView {
    @MainActor class ViewModel: ObservableObject {
        enum LoadingState {
            case loading, loaded, failed(error: Error)
        }

        @Published var name: String
        @Published var description: String

        @Published var loadingState = LoadingState.loading
        @Published var pages = [Page]()

        var location: Location
        var onSave: (Location) -> Void
        let session: AppleURLSession
        var subscriptions = Set<AnyCancellable>()

        init(session: AppleURLSession, location: Location, onSave: @escaping (Location) -> Void) {
            self.location = location
            self.onSave = onSave
            self.session = session

            name = location.name
            description = location.description
        }

        var nearbyUrl: URL {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"

            guard let url = URL(string: urlString) else { fatalError() }
            return url
        }

        // Async / Await
        func fetchNearbyPlaces() async {
            do {
                let items: WikiResult = try await fetchDataAsync(url: nearbyUrl)
                pages = items.query.pages.values.sorted()
                loadingState = .loaded
            } catch {
                loadingState = .failed(error: error)
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case let .invalidHTTPCode(code):
                        print("failure: \(code ?? 0)")
                    default:
                        print("failure")
                    }
                }
            }
        }

        func fetchDataAsync<Value>(url: URL) async throws -> Value where Value: Decodable {
            let (data, response) = try await session.data(from: url, delegate: nil)
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, !(200 ..< 300).contains(statusCode) {
                throw NetworkError.invalidHTTPCode(code: statusCode)
            }
            return try JSONDecoder().decode(Value.self, from: data)
        }

        // Combine
        func fetchNearby() {
            fetchWikiResult()
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case let .failure(error):
                        print("Couldn't get result: \(error)")
                        self.loadingState = .failed(error: error)
                        if let networkError = error as? NetworkError {
                            switch networkError {
                            case let .invalidHTTPCode(code):
                                print("failure: \(code ?? 0)")
                            default:
                                print("failure")
                            }
                        }
                    case .finished: break
                    }
                }) { result in
                    self.pages = result.query.pages.values.sorted()
                    self.loadingState = .loaded
                }
                .store(in: &subscriptions)
        }

        func fetchWikiResult() -> AnyPublisher<WikiResult, Error> {
            return fetchDataPublisher(url: nearbyUrl)
        }

        func fetchDataPublisher<Value>(url: URL) -> AnyPublisher<Value, Error> where Value: Decodable {
            return session.dataTaskPublisher(for: url)
                .tryMap { element -> Data in
                    if let statusCode = (element.response as? HTTPURLResponse)?.statusCode, !(200 ..< 300).contains(statusCode) {
                        throw NetworkError.invalidHTTPCode(code: statusCode)
                    }
                    return element.data
                }
                .decode(type: Value.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }

        // Closures
        func fetchPlaces() {
            returnOnMain(url: nearbyUrl) { result in
                switch result {
                case .failure(let error):
                    self.loadingState = .failed(error: error)
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case let .invalidHTTPCode(code):
                            print("failure: \(code ?? 0)")
                        default:
                            print("failure")
                        }
                    }
                case .success(let items):
                    self.pages = items.query.pages.values.sorted()
                    self.loadingState = .loaded
                }
            }
        }

        func returnOnMain(url: URL, callback: @escaping (Result<WikiResult, Error>) -> ()) {
            fetchDataClosure(url: url) { result in
                DispatchQueue.main.async {
                    callback(result)
                }
            }
        }

        func fetchDataClosure<Value>(url: URL, callback: @escaping (Result<Value, Error>) -> ()) where Value: Decodable {
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    callback(.failure(error))
                    return
                }
                if let statusCode = (response as? HTTPURLResponse)?.statusCode, !(200 ..< 300).contains(statusCode) {
                    callback(.failure(NetworkError.invalidHTTPCode(code: statusCode)))
                    return
                }
                guard let data = data else {
                    callback(.failure(NetworkError.noDataReturned))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(Value.self, from: data)
                    callback(.success(result))
                } catch {
                    callback(.failure(error))
                }
            }
            task.resume()
        }
    }
}
