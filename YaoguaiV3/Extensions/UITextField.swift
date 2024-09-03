//
//  UITextField.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 3/9/2024.
//

import Foundation
import UIKit

extension UITextField {
	/// Checks if the entire text in the UITextField is highlighted/selected.
	var isAllTextSelected: Bool {
		guard let selectedRange = selectedTextRange else { return false }
		
		// Get the start and end positions of the text field
		let beginning = self.beginningOfDocument
		let end = self.endOfDocument
		
		// Check if the selected range covers the entire text
		return selectedRange.start == beginning && selectedRange.end == end
	}
}
