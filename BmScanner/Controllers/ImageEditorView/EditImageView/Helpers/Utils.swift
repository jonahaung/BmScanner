import UIKit
import AVFoundation

class Utils {

    // Subscribes target to default NotificationCenter .UIDeviceOrientationDidChange
    static func subscribeToDeviceOrientationNotifications(_ target: AnyObject, selector: Selector) {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()

        let center = NotificationCenter.default
        let name =  UIDevice.orientationDidChangeNotification
        let selector = selector
        center.addObserver(target, selector: selector, name: name, object: nil)
    }

    static func unsubscribeFromOrientationNotifications(_ target: AnyObject) {
        let center = NotificationCenter.default
        center.removeObserver(target)

        //UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    static func videoOrientationFromDeviceOrientation(
        videoOrientation: AVCaptureVideoOrientation) -> AVCaptureVideoOrientation {
        let deviceOrientation = UIDevice.current.orientation

        switch deviceOrientation {
        case .unknown:
            return videoOrientation
        case .portrait:
            // Device oriented vertically, home button on the bottom
            return .portrait
        case .portraitUpsideDown:
            // Device oriented vertically, home button on the top
            return .portraitUpsideDown
        case .landscapeLeft:
            // Device oriented horizontally, home button on the right
            return .landscapeRight
        case .landscapeRight:
            // Device oriented horizontally, home button on the left
            return .landscapeLeft
        case .faceUp:
            // Device oriented flat, face up
            return videoOrientation
        case .faceDown:
            // Device oriented flat, face down
            return videoOrientation
				@unknown default:
						fatalError()
			}
    }

    static func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let deviceOrientation = UIDevice.current.orientation

        switch deviceOrientation {
        case .portraitUpsideDown:  // Device oriented vertically, home button on the top
            return .left
        case .landscapeLeft:       // Device oriented horizontally, home button on the right
            return .upMirrored
        case .landscapeRight:      // Device oriented horizontally, home button on the left
            return .down
        case .portrait:            // Device oriented vertically, home button on the bottom
            return .up
        default:
            return .up
        }
    }

    static func imageOrientationFromInterfaceOrientation() -> UIImage.Orientation {
        let interfaceOrientation = UIApplication.shared.statusBarOrientation

        switch interfaceOrientation {
        case .portrait:
            return .right
        case .portraitUpsideDown:
            return .left
        case .landscapeRight:
            return .up
        case .landscapeLeft:
            return .down

        default:
            return .right
        }
    }

    static func contentModeFromInterfaceOrientation(for image: UIImage) -> UIView.ContentMode {
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        let imageOrientation = image.imageOrientation

        switch (interfaceOrientation, imageOrientation) {
        case (.portrait, .right),
             (.portrait, .left),

             (.portraitUpsideDown, .left),
             (.portraitUpsideDown, .right),

             (.landscapeLeft, .up),
             (.landscapeLeft, .down),

             (.landscapeRight, .up),
             (.landscapeRight, .down):
            return .scaleAspectFill

        default:
            return .scaleAspectFit
        }
    }

    static var isIPhoneX: Bool {
      if UIDevice.current.userInterfaceIdiom == .phone {
        return UIScreen.main.nativeBounds.height >= 1792 // iPhone XR
      }

      return false
    }
}

extension UIView {

    func anchor(animated: Bool, top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        //translate the view's autoresizing mask into Auto Layout constraints
        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }

        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }

        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }

        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }

        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }

        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.layoutIfNeeded()
        }
    }
}


struct Layout {
    
    let element: UIView
    
    init(_ element: UIView) {
        self.element = element
    }
    
    // MARK: Layout
    
    @discardableResult func pinHorizontalEdgesToSuperView(padding: CGFloat = 0) -> [NSLayoutConstraint] {
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[view]-(padding)-|",
                                                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                        metrics: ["padding": padding],
                                                        views: ["view": element])
        safeSuperview().addConstraints(constraints)
        return constraints
    }
    
    @discardableResult func pinVerticalEdgesToSuperView(padding: CGFloat = 0) -> [NSLayoutConstraint] {
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(padding)-[view]-(padding)-|",
                                                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                        metrics: ["padding": padding],
                                                        views: ["view": element])
        safeSuperview().addConstraints(constraints)
        return constraints
    }
    
    @discardableResult func centerVertically() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .centerY,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .centerY,
                                            multiplier: 1.0, constant: 0)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func centerHorizontally() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .centerX,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .centerX,
                                            multiplier: 1.0, constant: 0)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func pinLeadingToSuperview(constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .leading,
                                            multiplier: 1, constant: constant)
        
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func pinTrailingToSuperview(constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .trailing,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func pinTopToSuperview(constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: safeSuperview(),
                                            attribute: .top,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func pinTopToView(view:UIView,constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .top,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    @discardableResult func pinBottomToView(view:UIView,constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: element,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .bottom,
                                            multiplier: 1, constant: constant)
        safeSuperview().addConstraint(constraint)
        return constraint
    }
    
    func fillSuperview(padding: CGFloat = 0) {
        safeSuperview()
        pinHorizontalEdgesToSuperView(padding: padding)
        pinVerticalEdgesToSuperView(padding: padding)
    }
    
    @discardableResult private func safeSuperview() -> UIView {
        element.translatesAutoresizingMaskIntoConstraints = false
        guard let view = element.superview else {
            fatalError("You need to have a superview before you can add contraints")
        }
        return view
    }
    
}


extension UIView {
    
    var layout: Layout {
        return Layout(self)
    }
    
}
