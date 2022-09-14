//
//  EditView-ViewModel.swift
//  Bucketlist
//
//  Created by Charles Bartel on 9/13/22.
//

import Foundation
import SwiftUI

extension EditView {
    @MainActor class ViewModel: ObservableObject {
        enum LoadingState {
            case loading, loaded, failed
        }

        @Published var name: String
        @Published var description: String

        @Published var loadingState = LoadingState.loading
        @Published var pages = [Page]()

        var location: Location
        var onSave: (Location) -> Void

        init(location: Location, onSave: @escaping (Location) -> Void) {
            self.location = location
            self.onSave = onSave

            self.name = location.name
            self.description = location.description
        }

        func fetchNearbyPlaces() async {
            do {
                let items: Result = try await fetchData(url: nearbyUrl)
                pages = items.query.pages.values.sorted()
                loadingState = .loaded
            } catch {
                loadingState = .failed
            }
        }

        var nearbyUrl: URL {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"

            guard let url = URL(string: urlString) else { fatalError() }
            return url
        }

        enum NetworkError : Error {
            case invalidHTTPCode(code: Int?)
        }

        func fetchData<Value>(url: URL) async throws -> Value where Value: Decodable {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                throw NetworkError.invalidHTTPCode(code: nil)
            }
            guard (200 ..< 300).contains(statusCode) else {
                throw NetworkError.invalidHTTPCode(code: statusCode)
            }
            return try JSONDecoder().decode(Value.self, from: data)
        }
    }
}
