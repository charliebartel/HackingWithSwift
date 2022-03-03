//
//  ExpenseItem.swift
//  iExpense
//
//  Created by Paul Hudson on 01/11/2021.
//

import Foundation

enum ExpenseType: String, Codable, CaseIterable {
    case business = "Business"
    case personal = "Personal"
}

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: ExpenseType
    let amount: Double
}
