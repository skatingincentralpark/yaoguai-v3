//
//  SpecialFocusTextFieldStyle.swift
//  yaoguai-v2
//
//  Created by Charles Zhao on 5/7/2024.
//

import Foundation
import SwiftUI

struct SpecialFocusTextFieldStyle: TextFieldStyle {
	var focused: Bool
	
	func _body(configuration: TextField<Self._Label>) -> some View {
		configuration
			.textFieldStyle(.roundedBorder)
			.overlay {
				if focused {
					RoundedRectangle(cornerRadius: 6.0)
						.strokeBorder()
				}
			}
	}
}

extension TextFieldStyle where Self == SpecialFocusTextFieldStyle {
	static func specialFocus(focused: Bool) -> Self {
		SpecialFocusTextFieldStyle(focused: focused)
	}
}

