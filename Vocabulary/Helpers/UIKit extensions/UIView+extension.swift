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

    static func instantiate<T: UIView>() -> T {
        
        let identifier = String(describing: T.self)
        let nib = UINib.init(nibName: identifier, bundle: nil)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? T else {
            fatalError("Could not instantiate \(identifier)")
        }
        return view
    }
	
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
