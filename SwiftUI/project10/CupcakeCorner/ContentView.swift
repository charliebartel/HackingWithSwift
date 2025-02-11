//
//  ContentView.swift
//  CupcakeCorner
//
//  Created by Paul Hudson on 17/11/2021.
//

import SwiftUI

struct ContentView: View {
    @StateObject var order = Order()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Select your cake type", selection: $order.model.type) {
                        ForEach(CakeType.allCases, id: \.self) { value in
                            Text(value.rawValue)
                                .tag(value)
                        }
                    }

                    Stepper("Number of cakes: \(order.model.quantity)", value: $order.model.quantity, in: 3...20)
                }

                Section {
                    Toggle("Any special requests?", isOn: $order.specialRequestEnabled.animation())

                    if order.specialRequestEnabled {
                        Toggle("Add extra frosting", isOn: $order.model.extraFrosting)
                        Toggle("Add extra sprinkles", isOn: $order.model.addSprinkles)
                    }
                }

                Section {
                    NavigationLink {
                        AddressView(order: order)
                    } label: {
                        Text("Delivery details")
                    }
                }
            }
            .navigationTitle("Cupcake Corner")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
