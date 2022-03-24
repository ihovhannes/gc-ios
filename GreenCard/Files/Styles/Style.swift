import UIKit
import Look

struct Style {
	static var window: Change<UIWindow> {
		return { (window: UIWindow) -> Void in
			window.tintColor = Palette.Window.tint.color
		}
	}
}

extension Style {
  static func corners(rounded: Bool, size: CGSize, radius: CGFloat) -> Change<UIView> {
    return { [rounded, size, radius] (view: UIView) -> Void in
      switch rounded {
      case true:
        let mask = CAShapeLayer()
        let path = UIBezierPath(roundedRect: CGRect.init(origin: .zero, size: size), cornerRadius: radius)
        mask.path = path.cgPath
        view.layer.mask = mask
      default:
        view.layer.mask = nil
      }
    }
  }

  static func border(bordered: Bool, size: CGSize, radius: CGFloat,
                     lineWidth: CGFloat, color: UIColor) -> Change<UIView> {
    return { [bordered, lineWidth, color] (view: UIView) -> Void in
      switch bordered {
      case true:
        let borderLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: CGRect.init(origin: .zero, size: size), cornerRadius: radius)
        borderLayer.path = path.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineWidth = lineWidth
        borderLayer.frame = view.bounds
        view.layer.addSublayer(borderLayer)
      default:
				view.layer.sublayers?.first { (layer) -> Bool in
					return layer.isKind(of: CAShapeLayer.self)
				}?.removeFromSuperlayer()
        debugPrint("remove border")
      }

    }
  }
}
