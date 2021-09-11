//
//  TimeZone+ItemProvider.swift
//  TimeZone+ItemProvider
//
//  Created by David on 11/09/2021.
//

import Foundation
import UniformTypeIdentifiers

let jsonEncoder = JSONEncoder()

extension TimeZone {
    class ItemProvider: NSObject, NSItemProviderWriting, Codable {
        let identifier: String
        let name: String?
        let abbreviation: String?
        let flag: String
        
        var resolvedName: String {
            "\(self.flag) \(self.name ?? self.identifier)"
        }
        
        init(from timezone: TimeZone) {
            self.identifier = timezone.identifier
            self.name = timezone.localizedName(for: .standard, locale: .current)
            self.abbreviation = timezone.abbreviation()
            self.flag = flagForTimeZone(timezone)
        }
        
        static var writableTypeIdentifiersForItemProvider: [String] = [
            UTType.json.identifier,
            UTType.text.identifier, UTType.utf8PlainText.identifier, UTType.plainText.identifier
        ]
        
        func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
            switch typeIdentifier {
            case UTType.json.identifier:
                return self.loadJson(forItemProviderCompletionHandler: completionHandler)
            case UTType.text.identifier,
                UTType.utf8PlainText.identifier,
                UTType.plainText.identifier:
                return self.loadUtf8String(forItemProviderCompletionHandler: completionHandler)
            default:
                completionHandler(nil, ItemProviderError.unrecognisedType(identifier: typeIdentifier))
                return nil
            }
        }
        
        func loadJson(forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
            do {
                completionHandler(try jsonEncoder.encode(self), nil)
            } catch {
                completionHandler(nil, error)
            }
            return nil
        }
        
        func loadUtf8String(forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
            completionHandler(Data(self.resolvedName.utf8), nil)
            return nil
        }
    }
    
    var itemProvider: ItemProvider {
        TimeZone.ItemProvider(from: self)
    }
}

enum ItemProviderError: LocalizedError {
    case unrecognisedType(identifier: String)
    
    var errorDescription: String? {
        return String.localizedStringWithFormat(NSLocalizedString("ItemProvidingFailed: %@", tableName: "Errors", comment: ""), failureReason!)
    }
    
    var failureReason: String? {
        switch self {
        case .unrecognisedType(let identifier):
            return String.localizedStringWithFormat(NSLocalizedString("UnrecognisedUTI: %@", tableName: "Errors", comment: ""), identifier)
        }
    }
    
    var recoverySuggestion: String? {
        "Please contact support"
    }
}
