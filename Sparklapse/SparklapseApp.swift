//
//  SparklapseApp.swift
//  Sparklapse
//
//  Created by Ashot Kirakosyan on 29.10.25.
//

import SwiftUI

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            LaunchView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    static var orientationMask: UIInterfaceOrientationMask = .portrait

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        Self.orientationMask
    }
}
