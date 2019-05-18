//
//	UITableViewHeaderFooterView+extention.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 10/31/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

extension UITableViewHeaderFooterView {
	
	func addTrailingButton(_ button: UIButton) {
		button.sizeToFit()
		button.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(button)
		
		NSLayoutConstraint.activate([
			button.heightAnchor.constraint(equalToConstant: button.bounds.height),
			button.widthAnchor.constraint(equalToConstant: button.bounds.width),
			button.bottomAnchor.constraint(equalTo: contentView.lastBaselineAnchor),
			button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0)
		])
	}
}

