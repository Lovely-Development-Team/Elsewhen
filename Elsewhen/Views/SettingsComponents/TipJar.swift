//
//  TipJar.swift
//  Elsewhen
//
//  Created by Ben Cardy on 24/01/2022.
//

import SwiftUI
import StoreKit

struct Tip: View {
    
    let iap: SKProduct
    @ObservedObject var storeKitController: StoreKitController
    @State private var showThankYouAlert = false
    private let currencyFormatter = NumberFormatter()
    
    var formatCurrency: String {
        currencyFormatter.locale = iap.priceLocale
        currencyFormatter.numberStyle = .currency
        return currencyFormatter.string(from: iap.price) ?? ""
    }
    
    var body: some View {
        Button(action: {
            storeKitController.purchaseProduct(product: iap)
        }) {
            HStack {
                Text(iap.localizedTitle)
                Spacer()
                if storeKitController.pendingPurchases.contains(iap.productIdentifier) {
                    ProgressView()
                } else {
                    Text(formatCurrency)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .init(rawValue: "TransactionPaymentPurchased"), object: nil), perform: { (notification) in
            showThankYouAlert = true
        })
        .alert(isPresented: $showThankYouAlert) {
            Alert(title: Text("Thank you!"), message: Text("Your tip is much appreciated, thank you for your support!"), dismissButton: .default(Text("Seriously, thank you"), action: {}))
        }
    }
    
}

struct TipJar: View {
    
    @StateObject private var storeKitController = StoreKitController()
    
    var content: some View {
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
                    Tip(iap: iap, storeKitController: storeKitController)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Tip Jar")
        .onAppear {
            storeKitController.getProducts(productIDs: [
                "uk.co.bencardy.Elsewhen.IAP.Test"
            ])
            SKPaymentQueue.default().add(storeKitController)
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
