//
//  UIApplication+clearLaunchScreenCache.swift
//  UIApplication+clearLaunchScreenCache
//
//  Created by David on 09/09/2021.
//
// Copied from: https://rambo.codes/posts/2019-12-09-clearing-your-apps-launch-screen-cache-on-ios

import UIKit

public extension UIApplication {

    func clearLaunchScreenCache() {
        do {
            try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Library/SplashBoard")
        } catch {
            logger.warning("Failed to delete launch screen cache: \(error.localizedDescription)")
        }
    }

}
