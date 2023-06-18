//
//	CardCollectionView.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 5/14/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class CardCollectionView: UICollectionViewCell {
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setupCorners()
		setupShadows()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		setupShadowPath(for: frame.size)
	}
	
	private func setupCorners() {
		layer.cornerRadius = cornerRadius
		layer.masksToBounds = false
		
		contentView.layer.cornerRadius = cornerRadius
		contentView.layer.masksToBounds = true
	}
	
	private func setupShadows() {
		layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
		layer.shadowRadius = 6.0
		layer.shadowOpacity = 0.2
	}
	
	func setupShadowPath(for size: CGSize) {
		let rect: CGRect = CGRect(origin: CGPoint.zero, size: size)
		layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
	}
}
