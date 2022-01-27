//
//  StoreKitController.swift
//  Elsewhen
//
//  Created by Ben Cardy on 24/01/2022.
//

import Foundation
import StoreKit

class StoreKitController: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @Published var iaps = [SKProduct]()
    @Published var pendingPurchases: Set<String> = []
    var request: SKProductsRequest!
    
    func getProducts(productIDs: [String]) {
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            DispatchQueue.main.async {
                for fetchedProduct in response.products.sorted(by: {$0.price.floatValue < $1.price.floatValue}) {
                        self.iaps.append(fetchedProduct)
                }
            }
        }
    }
    
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            pendingPurchases.insert(product.productIdentifier)
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("User can't make payment.")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        let queue = SKPaymentQueue.default()
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                queue.finishTransaction(transaction)
                NotificationCenter.default.post(name: .init("TransactionPaymentPurchased"), object: transaction.payment.productIdentifier)
                pendingPurchases.remove(transaction.payment.productIdentifier)
            case .failed:
                queue.finishTransaction(transaction)
                pendingPurchases.remove(transaction.payment.productIdentifier)
            default:
                continue
            }
        }
    }
    
}
