//
//  ImageResource.swift
//
//
//  Created by Ernest Chechelski on 15/12/2023.
//

import Combine
import UIKit

protocol ImageResource {
  var uiImage: AnyPublisher<UIImage, Error> { get }
}
