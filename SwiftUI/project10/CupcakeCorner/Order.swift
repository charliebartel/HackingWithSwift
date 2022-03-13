//
//  Order.swift
//  CupcakeCorner
//
//  Created by Paul Hudson on 18/11/2021.
//

import SwiftUI

extension String {
    var isEmptyOrWhitespace: Bool {
        if self.isEmpty {
            return true
        }
        return (self.trimmingCharacters(in: .whitespaces) == "")
    }
}

struct OrderDTO: Codable {
    var type: CakeType
    var quantity: Int
    var extraFrosting: Bool
    var addSprinkles: Bool
    var name: String
    var streetAddress: String
    var city: String
    var zip: String
}

enum CakeType: String, Codable, CaseIterable {    
    case vanilla
    case strawberry
    case chocolate
    case rainbow
}

class Order: ObservableObject {
    @Published var model: OrderDTO

    @Published var specialRequestEnabled = false {
        didSet {
            if specialRequestEnabled == false {
                model.extraFrosting = false
                model.addSprinkles = false
            }
        }
    }

    var hasValidAddress: Bool {
        if model.name.isEmptyOrWhitespace ||
            model.streetAddress.isEmptyOrWhitespace ||
            model.city.isEmptyOrWhitespace ||
            model.zip.isEmptyOrWhitespace {
            return false
        }

        return true
    }

    var cost: Double {
        // $2 per cake
        var cost = Double(model.quantity) * 2

        // $1/cake for extra frosting
        if model.extraFrosting {
            cost += Double(model.quantity)
        }

        // $0.50/cake for sprinkles
        if model.addSprinkles {
            cost += Double(model.quantity) / 2
        }

        return cost
    }

    init() {
        self.model = OrderDTO(type: .chocolate,
                                quantity: 15,
                                extraFrosting: false,
                                addSprinkles: false,
                                name: "Ruth Bartel",
                                streetAddress: "Purdue",
                                city: "Bikemont",
                                zip: "80503")
    }
}
