//
//  AppDelegate.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  nikans.com
//

import UIKit
import MonarchRouter



@main
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var appRouter: ProvidesRouteDispatch?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // iOS 13 and above
        // Set up router in scene delegate
        if #available(iOS 13, *) {
            return true
        }
        
        // iOS 12 and below
        // Set up router here
        else {
            // Setting up a window
            window = UIWindow(frame: UIScreen.main.bounds)
            
            window?.makeKeyAndVisible()
            
            // Callback to set root VC. You can extend it with animations, etc.
            let setRootViewController: (_ vc: UIViewController) -> () = { vc in
                guard
                    let window = self.window,
                    vc != window.rootViewController
                else { return }
                
                window.rootViewController = vc
            }
            
            // Initializing Router and setting root VC
            var coordinator: RoutingNodeType!
            let router = RouterStore(router: coordinator)
            coordinator = appCoordinator(router: router, setRootView: setRootViewController)
            
            appRouter = router
            
            // Presenting the default Route
            appRouter?.dispatch(.login)
            
            return true
        }
    }


    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
