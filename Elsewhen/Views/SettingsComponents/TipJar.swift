//
//  TipJar.swift
//  Elsewhen
//
//  Created by Ben Cardy on 24/01/2022.
//

import SwiftUI
import StoreKit

struct TipJar: View {
    
    @StateObject private var storeKitController = StoreKitController()
    private let currencyFormatter = NumberFormatter()
    
    private func formatCurrency(for product: SKProduct) -> String {
        currencyFormatter.locale = product.priceLocale
        currencyFormatter.numberStyle = .currency
        return currencyFormatter.string(from: product.price) ?? ""
    }
    
    var content: some View {
//        ScrollView {
            VStack(spacing: 10) {
                VStack(spacing: 10) {
                    Text("Elsewhen is and always will be free.")
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    Text("However, if you find the app useful, consider leaving us a tip! It won't unlock any features, other than the warm glow in your heart that is our gratitude.")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    Text("Thank you for using Elsewhen!")
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                if storeKitController.iaps.isEmpty {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    List(storeKitController.iaps, id: \.self) { iap in
                        Button(action: {
                            
                        }) {
                            HStack {
                                Text(iap.localizedTitle)
                                Spacer()
                                Text(formatCurrency(for: iap))
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
//        }
        .navigationTitle("Tip Jar")
        .onAppear {
            storeKitController.getProducts(productIDs: [
                "uk.co.bencardy.Elsewhen.IAP.Test"
            ])
        }
    }
    
    var body: some View {
        if DeviceType.isPadAndNotCompact {
            NavigationView {
                content
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            content
        }
    }
    
}

struct TipJar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TipJar()
        }
    }
}
