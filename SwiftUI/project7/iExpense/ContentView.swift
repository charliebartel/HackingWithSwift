//
//  ContentView.swift
//  iExpense
//
//  Created by Paul Hudson on 01/11/2021.
//

import SwiftUI

extension ExpenseItem {
    var color: Color {
        if amount > 100 {
            return .red
        } else if amount > 10 {
            return .blue
        }
        return .black
    }
}

struct ExpenseView: View {
    var item: ExpenseItem

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text(item.type.rawValue)
            }

            Spacer()

            Text(item.amount, format: .currency(code: Locale.current.currencyCode ?? "USD"))
                .foregroundColor(item.color)
        }
    }
}

struct ContentView: View {
    @StateObject var expenses = Expenses()
    @State private var showingAddExpense = false

    var body: some View {
        NavigationView {
            List {
                Section(ExpenseType.personal.rawValue) {
                    ForEach(expenses.items.filter {$0.type == .personal}) { item in
                        ExpenseView(item: item)
                    }
                    .onDelete(perform: removePersonal)
                }
                Section(ExpenseType.business.rawValue) {
                    ForEach(expenses.items.filter {$0.type == .business}) { item in
                        ExpenseView(item: item)
                    }
                    .onDelete(perform: removeBusiness)
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
        }
    }

    func removePersonal(at offsets: IndexSet) {
        let index = offsets[offsets.startIndex]
        let item = expenses.items.filter {$0.type == .personal}[index]
        expenses.items.removeAll(where: { $0.id == item.id } )
    }

    func removeBusiness(at offsets: IndexSet) {
        let index = offsets[offsets.startIndex]
        let item = expenses.items.filter {$0.type == .business}[index]
        expenses.items.removeAll(where: { $0.id == item.id } )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
