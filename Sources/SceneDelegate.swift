import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("SceneDelegate: willConnectTo called")
        
        guard let windowScene = (scene as? UIWindowScene) else {
            print("SceneDelegate: Failed to cast scene to UIWindowScene")
            return
        }
        
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .white
        print("SceneDelegate: Created window with white background")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        print("SceneDelegate: Loaded Main storyboard")
        
        guard let viewController = storyboard.instantiateInitialViewController() else {
            print("SceneDelegate: Failed to instantiate initial view controller")
            return
        }
        
        viewController.view.backgroundColor = .white
        window?.rootViewController = viewController
        print("SceneDelegate: Set root view controller with white background")
        
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
