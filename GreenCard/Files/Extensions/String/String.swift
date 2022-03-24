//
// Created by Hovhannes Sukiasian on 16/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit

extension String {

    var utfData: Data? {
        return self.data(using: .utf8)
    }

    var htmlAttributedString: NSAttributedString? {
        guard let data = self.utfData else {
            return nil
        }
        do {
            return try NSAttributedString(data: data,
                    options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ], documentAttributes: nil)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func noWhitespace() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }

    func firstLetterUppercase() -> String {
        var result = self
        let firstLetter = String(self[self.startIndex]).uppercased()
        result.remove(at: result.startIndex)
        result.insert(firstLetter[firstLetter.startIndex], at: result.startIndex)
        return result
    }


}

extension Optional where Wrapped == String {

    func isEmpty() -> Bool {
        switch self {
        case .none:
            return true
        case .some(let value):
            return value == ""
        }
    }

}

extension String {

    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x2600...0x26FF,   // Misc symbols
                 0x2700...0x27BF,   // Dingbats
                 0xFE00...0xFE0F,   // Variation Selectors
                 0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                 0x1F1E6...0x1F1FF: // Flags
                return true
            default:
                continue
            }
        }
        return false
    }

}
