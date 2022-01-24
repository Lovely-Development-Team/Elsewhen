//
//  StoreKitController.swift
//  Elsewhen
//
//  Created by Ben Cardy on 24/01/2022.
//

import Foundation
import StoreKit

class StoreKitController: NSObject, ObservableObject, SKProductsRequestDelegate {
    
    @Published var iaps = [SKProduct]()
    var request: SKProductsRequest!
    
    func getProducts(productIDs: [String]) {
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.iaps.append(fetchedProduct)
                }
            }
        }
    }
    
}
