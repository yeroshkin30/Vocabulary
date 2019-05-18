//
//  CardCollectionViewCell.swift
//  Vocabulary
//
//  Created by Alexander Baraley on 11/29/17.
//  Copyright © 2017 Alexander Baraley. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
	
	private let cornerRadius: CGFloat = 20.0
	
    override func awakeFromNib() {
		super.awakeFromNib()
        setupCorners()
		setupShadows()
    }
	
	private func setupCorners() {
		layer.cornerRadius = cornerRadius
		layer.masksToBounds = false
		
		contentView.layer.cornerRadius = cornerRadius
		contentView.layer.masksToBounds = true
	}
	
	private func setupShadows() {
		layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
		layer.shadowColor = UIColor.gray.cgColor
		layer.shadowRadius = 2.0
		layer.shadowOpacity = 1.0
		updateShadow()
	}
	
	func updateShadow() {
		layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
	}
}
