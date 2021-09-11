//
//  TimeZone+ItemProvider.swift
//  TimeZone+ItemProvider
//
//  Created by David on 11/09/2021.
//

import Foundation
import UniformTypeIdentifiers

let jsonEncoder = JSONEncoder()
let jsonDecoder = JSONDecoder()

let typeIdentifiers = [
    UTType.json.identifier,
    UTType.text.identifier, UTType.utf8PlainText.identifier, UTType.plainText.identifier
]

extension TimeZone {
    class ItemProvider: NSObject, NSItemProviderWriting, Codable, NSItemProviderReading {
        
        let identifier: String
        let name: String?
        let abbreviation: String?
        let flag: String
        
        var resolvedName: String {
            "\(self.flag) \(self.name ?? self.identifier)"
        }
        
        required init(from timezone: TimeZone) {
            self.identifier = timezone.identifier
            self.name = timezone.localizedName(for: .standard, locale: .current)
            self.abbreviation = timezone.abbreviation()
            self.flag = flagForTimeZone(timezone)
        }
        
        static var writableTypeIdentifiersForItemProvider: [String] = typeIdentifiers
        
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
        
        static var readableTypeIdentifiersForItemProvider: [String] = typeIdentifiers
        
        static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
            switch typeIdentifier {
            case UTType.json.identifier:
                return try jsonDecoder.decode(Self.self, from: data)
            case UTType.text.identifier,
                UTType.utf8PlainText.identifier,
                UTType.plainText.identifier:
                guard let string = String(data: data, encoding: .utf8) else {
                    throw ItemProviderError.invalidData(representing: "TimeZone")
                }
                if let provider = Self.from(string: string) {
                    return provider
                }
                if let provider = Self.from(string: string.replacingOccurrences(of: "\\", with: "").trimmingCharacters(in: .punctuationCharacters)) {
                    return provider
                }
                if let provider = Self.from(string: string.dropFirst(1).trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .punctuationCharacters)) {
                    return provider
                }
                throw ItemProviderError.invalidData(representing: "TimeZone")
            default:
                throw ItemProviderError.unrecognisedType(identifier: typeIdentifier)
            }
        }
        
        static func from(string: String) -> Self? {
            if let tz = TimeZone(identifier: string) {
                return Self.init(from: tz)
            }
            if let tz = TimeZone(abbreviation: string) {
                return Self.init(from: tz)
            }
            return nil
        }
    }
    
    var itemProvider: ItemProvider {
        TimeZone.ItemProvider(from: self)
    }
}

enum ItemProviderError: LocalizedError {
    case unrecognisedType(identifier: String)
    case invalidData(representing: String)
    
    var errorDescription: String? {
        return String.localizedStringWithFormat(NSLocalizedString("ItemProvidingFailed: %@", tableName: "Errors", comment: ""), failureReason!)
    }
    
    var failureReason: String? {
        switch self {
        case .unrecognisedType(let identifier):
            return String.localizedStringWithFormat(NSLocalizedString("UnrecognisedUTI: %@", tableName: "Errors", comment: ""), identifier)
        case .invalidData(let representing):
            return "Data did not represent a \(representing)"
        }
    }
    
    var recoverySuggestion: String? {
        "Please contact support"
    }
}
