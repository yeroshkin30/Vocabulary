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
		
		guard let sefeAreaSize = collectionView?.safeAreaLayoutGuide.layoutFrame.size else { return }
		
		itemSize = CGSize(width: sefeAreaSize.width * 0.85, height: sefeAreaSize.height * 0.85)
		
		let gorizontalInset = (sefeAreaSize.width - itemSize.width) / 2
		
		let heightInset = (sefeAreaSize.height - itemSize.height) / 2
		
		sectionInset = UIEdgeInsets.init(top: heightInset, left: gorizontalInset, bottom: heightInset, right: gorizontalInset)
		
		minimumLineSpacing = gorizontalInset * 2
	}
}
