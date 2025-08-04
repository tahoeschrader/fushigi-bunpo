//
//  JSONDecoder.swift
//  fushigi
//
//  Created by Tahoe Schrader on 2025/08/04.
//

import Foundation

extension JSONDecoder {
    /// A JSONDecoder configured to decode ISO8601 dates with fractional seconds from timestamptz
    static var iso8601withFractionalSeconds: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            guard let date = formatter.date(from: dateStr) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid date string: \(dateStr)"
                )
            }
            return date
        }
        return decoder
    }
}
