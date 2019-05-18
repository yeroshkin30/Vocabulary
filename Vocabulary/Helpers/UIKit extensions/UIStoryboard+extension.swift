//
//	StoryboardHelper.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/27/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

extension UIStoryboard {
	
	enum Storyboard: String {
		case home = "Home"
		case learning = "Learning"
		case wordsCollection = "Words"
	}
	
	convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
		self.init(name: storyboard.rawValue, bundle: bundle)
	}
	
	class func storyboard(storyboard: Storyboard, bundle: Bundle? = nil) -> UIStoryboard {
		return UIStoryboard(name: storyboard.rawValue, bundle: bundle)
	}

	func instantiateViewController<T: UIViewController>() -> T {
		let idenrifier = T.stringIdentifier
		guard let viewController = instantiateViewController(withIdentifier: idenrifier) as? T else {
			fatalError("Could not find view controller with name \(idenrifier)")
		}
		return viewController
	}
}
