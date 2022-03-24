//
//  LoginAnimatedView.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 31.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import Look

protocol LoginAnimatedView {

	var title: UILabel { get set }
	var background: UIView { get }

}

extension Style {
	static var loginAnimatedStyle: Change<LoginAnimatedView> {
		return { (view: LoginAnimatedView) -> Void in
			view.background.backgroundColor = Palette.LoginView.background.color
			view.title.textAlignment = .right
			
			view.title.textColor = Palette.LoginView.text.color
			guard let text = view.title.text else { return }
			let nsText = text as NSString
			let attributedText = NSMutableAttributedString(string: text)
			attributedText.addAttributes([NSAttributedStringKey.foregroundColor: Palette.LoginView.highlight.color],
			                             range: nsText.range(of: "ГРИН"))
			view.title.attributedText = attributedText
		}
	}
}
