//
//  AppDelegate.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import UIKit
import UserNotifications
import Intents
import WidgetKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    let appDependencies = DefaultAppDependencies(deviceName: UIDevice.current.name)

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        .portrait // Support only portrait for now.
    }
}
