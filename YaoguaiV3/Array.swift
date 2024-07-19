//
//  Array.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 20/7/2024.
//

import Foundation

extension Array where Element: Equatable {
	mutating func removeFirst(where predicate: (Element) throws -> Bool) rethrows {
		if let index = try self.firstIndex(where: predicate) {
			self.remove(at: index)
		}
	}
}
