//
//  Extensions.swift
//  LitProtocolSwiftSDK
//
//  Created by leven on 2023/1/13.
//

import Foundation
extension Collection where Element == String {
    
    
    var mostCommonString: String? {
        return self.sorted { first, second in
            return self.filter({ $0 == first }).count > self.filter({ $0 == second }).count
        }.first
        
    }
}

extension String {
    func asUrl() throws -> URL {
        if let url = URL(string: self) {
            return url
        }
        throw LitError.invalidUrl(self)
    }
}
