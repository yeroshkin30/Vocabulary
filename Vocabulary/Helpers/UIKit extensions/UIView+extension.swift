//
//	UIView+extension.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/23/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

//@IBDesignable
extension UIView {
	
	@IBInspectable var cornerRadius: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.cornerRadius = newValue
			layer.masksToBounds = newValue > 0
		}
	}
	
	@IBInspectable var borderWidth: CGFloat {
		get { return layer.borderWidth }
		set { layer.borderWidth = newValue }
	}
	
	@IBInspectable var borderColor: UIColor {
		get {
			let color = layer.borderColor ?? UIColor.clear.cgColor
			return UIColor(cgColor: color)
		}
		set {
			layer.borderColor = newValue.cgColor
		}
	}
	
	func select(with color: UIColor) {
		layer.borderColor = color.cgColor
		layer.borderWidth = 4.0
	}
	
	func deselect() {
		layer.borderWidth = 0.0
	}
}
