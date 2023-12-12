//
//  UIApplication+Extensions.swift
//  IOS_BASE
//

import UIKit

public extension UIApplication {
    static var currentKeyWindow: UIWindow? {
        UIApplication.shared.currentKeyWindow
    }

    static var rootViewController: UIViewController? {
        UIApplication.shared.rootViewController
    }

    var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }

    var currentKeyWindow: UIWindow? {
        connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }

    var viewControllers: [UIViewController] {
        (rootViewController as? UINavigationController)?.viewControllers ?? [rootViewController].compactMap { $0 }
    }

    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    static func dismissKeyboard() {
        shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
