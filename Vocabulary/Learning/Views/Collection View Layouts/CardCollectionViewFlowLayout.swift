//
//	CardCollectionViewFlowLayout.swift
//	Vocabulary
//
//	Created by Alexander Baraley on 8/30/18.
//	Copyright © 2018 Alexander Baraley. All rights reserved.
//

import UIKit

class CardCollectionViewFlowLayout: UICollectionViewFlowLayout {
	
	override func prepare() {
		
		guard let safeAreaSize = collectionView?.safeAreaLayoutGuide.layoutFrame.size else { return }
		
		itemSize = CGSize(width: safeAreaSize.width * 0.85, height: safeAreaSize.height * 0.85)
		
		let horizontalInset = (safeAreaSize.width - itemSize.width) / 2
		
		let heightInset = (safeAreaSize.height - itemSize.height) / 2
		
		sectionInset = UIEdgeInsets.init(top: heightInset, left: horizontalInset, bottom: heightInset, right: horizontalInset)
		
		minimumLineSpacing = horizontalInset * 2
	}
}
