//
//  UIView+Extensions.swift
//  Created by JechtSh0t on 6/10/23.
//

import UIKit

// MARK: - Animation -

extension UIView {
	
	@objc func animateBouncePress(_ sender: UIView) {
		animate(sender, transform: CGAffineTransform(scaleX: 0.9, y: 0.9))
	}
	
	@objc func animateBounceRelease(_ sender: UIView) {
		animate(sender, transform: .identity)
	}
	
	private func animate(_ sender: UIView, transform: CGAffineTransform) {
		
		UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
			sender.transform = transform
		})
	}
}
