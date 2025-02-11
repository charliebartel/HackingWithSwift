//
//  FilteredList.swift
//  Project12
//
//  Created by Paul Hudson on 17/02/2020.
//  Copyright © 2020 Paul Hudson. All rights reserved.
//

import CoreData
import SwiftUI

struct FilteredList<T: NSManagedObject, Content: View>: View {

    enum StringComparisons: String {
        case beginsWith = "BEGINSWITH"
        case contains = "CONTAINS"
        case endsWith = "ENDSWITH"
        case like = "LIKE"
        case matches = "MATCHES"
    }

    var fetchRequest: FetchRequest<T>
    var singers: FetchedResults<T> { fetchRequest.wrappedValue }

    // this is our content closure; we'll call this once for each item in the list
    let content: (T) -> Content

    var body: some View {
        List(fetchRequest.wrappedValue, id: \.self) { singer in
            self.content(singer)
        }
    }

    init(filterKey: String,
         predicate: StringComparisons,
         filterValue: String,
         sortDescriptors: [SortDescriptor<T>],
         @ViewBuilder content: @escaping (T) -> Content) {
        fetchRequest = FetchRequest<T>(sortDescriptors: sortDescriptors,
                                       predicate: NSPredicate(format: "%K \(predicate.rawValue) %@", filterKey, filterValue))
        self.content = content
    }
}

