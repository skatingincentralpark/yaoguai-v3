//
//  Collection.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 31/8/2024.
//

import Foundation

extension Collection {
	// Returns the element at the specified index if it is within bounds, otherwise nil.
	subscript(safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
