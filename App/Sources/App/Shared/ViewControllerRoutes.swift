//
//  ViewControllerRoutes.swift
//
//
//  Created by Ernest Chechelski on 14/12/2023.
//

import UIKit

///  Protocol which should extend and conform every ViewController.
protocol ViewControllerRoutes: AnyObject {
    /// As all view controller must conform this protocol, basic methods methods must be also accessible
    var viewController: UIViewController { get }
}

extension ViewControllerRoutes where Self: UIViewController {
    var viewController: UIViewController { self }
}
