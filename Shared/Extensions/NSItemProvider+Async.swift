//
//  NSItemProvider+Async.swift
//  ShareExtension
//
//  Created by Lucas Fischer on 01.03.22.
//  Copyright © 2022 Lucas Fischer. All rights reserved.
//

import Foundation
extension NSItemProvider {
    func loadItemAsync(forTypeIdentifier: String, options: [AnyHashable : Any]? = nil) async throws -> NSSecureCoding? {
        try await withCheckedThrowingContinuation { continuation in
            self.loadItem(forTypeIdentifier: forTypeIdentifier, options: options) { (item, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                else {
                    continuation.resume(returning: item)
                }
            }
        }
    }
}
