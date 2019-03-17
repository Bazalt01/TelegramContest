//
//  UIImage+Additional.swift
//  TelegramContest
//
//  Created by g.tokmakov on 18/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

public extension UIImage {
    class func ts_image(imageName: String, renderingMode: UIImage.RenderingMode) -> UIImage? {
        return UIImage(named: imageName)?.withRenderingMode(renderingMode)
    }
}
