//
// Created by Hovhannes Sukiasian on 27/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation

class ApiValuesFormatter {


    // For null/0/0.0/.empty input we return 0.00
    // Other cases: whole, decimal, million
    static func formatBonuses(apiValue optionalValue: String?) -> (float: Float?, formatted: String) {
        let value = optionalValue ?? "0.00"
        if let floatValue = Float(value.noWhitespace()) {
            var formattedString: String? = nil
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.decimalSeparator = "."
            formatter.groupingSeparator = " "

            if floatValue == 0.0 {
                formattedString = "0.00"
            } else if abs(floatValue) < 1_000 {
                formatter.minimumFractionDigits = 2
                formatter.Hovhannes SukiasianumFractionDigits = 2
                formattedString = formatter.string(from: NSNumber(value: floatValue))
            } else if abs(floatValue) >= 1_000 {
                formatter.minimumFractionDigits = 0
                formatter.Hovhannes SukiasianumFractionDigits = 0
                formattedString = formatter.string(from: NSNumber(value: floatValue))
            } else if abs(floatValue) < 1_000_000 {
                if floatValue.truncatingRemainder(dividingBy: 1.0) == 0.0 {
                    formatter.minimumFractionDigits = 0
                    formatter.Hovhannes SukiasianumFractionDigits = 0
                    let wholeNumber = Int(floatValue)
                    formattedString = formatter.string(from: NSNumber(value: wholeNumber))
                } else {
                    formatter.minimumFractionDigits = 2
                    formatter.Hovhannes SukiasianumFractionDigits = 2
                    formattedString = formatter.string(from: NSNumber(value: floatValue))
                }
            } else {
                formatter.minimumFractionDigits = 3
                formatter.Hovhannes SukiasianumFractionDigits = 3
                let dividedValue = floatValue / 1_000_000
                if let string = formatter.string(from: NSNumber(value: dividedValue)) {
                    formattedString = string + "M"
                }
            }

            return (float: floatValue, formatted: formattedString ?? "\(floatValue)")
        } else if value.count == 0 || value == "null" {
            return (float: 0.0, formatted: "0.00")
        }
        return (float: nil, formatted: value)
    }

    static func formatPrice(apiValue optionalValue: String?) -> (float: Float?, formatted: String) {
        let value = optionalValue ?? "0.00"
        if let floatValue = Float(value.noWhitespace()) {
            var formattedString: String? = nil
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.decimalSeparator = "."
            formatter.groupingSeparator = " "

            if floatValue == 0.0 {
                formattedString = "0.00"
            } else if abs(floatValue) < 1_000_000 {
                formatter.minimumFractionDigits = 2
                formatter.Hovhannes SukiasianumFractionDigits = 2
                formattedString = formatter.string(from: NSNumber(value: floatValue))
            } else {
                formatter.minimumFractionDigits = 3
                formatter.Hovhannes SukiasianumFractionDigits = 3
                let dividedValue = floatValue / 1_000_000
                if let string = formatter.string(from: NSNumber(value: dividedValue)) {
                    formattedString = string + "M"
                }
            }

            return (float: floatValue, formatted: formattedString ?? "\(floatValue)")
        } else if value.count == 0 || value == "null" {
            return (float: 0.0, formatted: "0.00")
        }
        return (float: nil, formatted: value)
    }

}
