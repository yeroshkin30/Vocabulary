//
//	StoryboardHelper.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 3/27/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

extension UIStoryboard {
	
	enum StoryboardName: String {
		case main = "Main"
		case learning = "Learning"
		case search = "Search"
		case words = "Words"
	}
	
	convenience init(storyboard: StoryboardName, bundle: Bundle? = nil) {
		self.init(name: storyboard.rawValue, bundle: bundle)
	}
	
	class func storyboard(storyboard: StoryboardName, bundle: Bundle? = nil) -> UIStoryboard {
		return UIStoryboard(name: storyboard.rawValue, bundle: bundle)
	}

	func instantiateViewController<T: UIViewController>() -> T {
		let identifier = T.stringIdentifier
		guard let viewController = instantiateViewController(withIdentifier: identifier) as? T else {
			fatalError("Could not find view controller with name \(identifier)")
		}
		return viewController
	}
}
