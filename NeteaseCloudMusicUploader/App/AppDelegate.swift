//
//  AppDelegate.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/2.
//

import Cocoa
import UIFoundation
import NeteaseCloudMusicService

@MainActor
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    class var shared: AppDelegate { NSApplication.shared.delegate as! AppDelegate }

    lazy var appServices: AppServices = .init()

    lazy var appCoordinator: AppCoordinator = .init(appServices: appServices)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        appCoordinator.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @IBAction func settingsMenuItemAction(_ sender: NSMenuItem) {
        appCoordinator.trigger(.settings)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag { return false }
        sender.windows.first?.makeKeyAndOrderFront(true)
        return false
    }
}
