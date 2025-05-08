import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("SceneDelegate: willConnectTo called")
        
        guard let windowScene = (scene as? UIWindowScene) else {
            print("SceneDelegate: Failed to cast scene to UIWindowScene")
            return
        }
        
        // Create and configure window
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .white
        print("SceneDelegate: Created window with white background")
        
        // Load and configure view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        print("SceneDelegate: Loaded Main storyboard")
        
        guard let viewController = storyboard.instantiateInitialViewController() else {
            print("SceneDelegate: Failed to instantiate initial view controller")
            return
        }
        
        // Force view to load and set background color
        _ = viewController.view
        viewController.view.backgroundColor = .white
        print("SceneDelegate: Configured view controller with white background")
        
        // Set up window hierarchy
        window?.rootViewController = viewController
        window?.backgroundColor = .white // Set again after root view controller
        print("SceneDelegate: Set root view controller with white background")
        
        // Make window visible
        window?.makeKeyAndVisible()
        print("SceneDelegate: Made window key and visible")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("SceneDelegate: sceneDidDisconnect")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("SceneDelegate: sceneDidBecomeActive")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("SceneDelegate: sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("SceneDelegate: sceneWillEnterForeground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("SceneDelegate: sceneDidEnterBackground")
    }
}
