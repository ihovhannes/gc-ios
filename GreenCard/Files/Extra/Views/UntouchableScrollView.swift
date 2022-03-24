//
//  UntouchableScrollView.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 02.08.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit

class UntouchableScrollView: UIScrollView {
	
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let result = super.hitTest(point, with: event)
		if result == self { return nil }
		return result
	}
}
