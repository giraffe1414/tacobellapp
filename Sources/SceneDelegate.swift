import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("SceneDelegate: willConnectTo called")
        
        guard let windowScene = (scene as? UIWindowScene) else {
            print("SceneDelegate: Failed to cast scene to UIWindowScene")
            return
        }
        
        do {
            window = UIWindow(windowScene: windowScene)
            print("SceneDelegate: Created window")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            print("SceneDelegate: Loaded Main storyboard")
            
            guard let viewController = storyboard.instantiateInitialViewController() else {
                print("SceneDelegate: Failed to instantiate initial view controller")
                return
            }
            
            window?.rootViewController = viewController
            print("SceneDelegate: Set root view controller")
            
            window?.backgroundColor = .white
            window?.makeKeyAndVisible()
            print("SceneDelegate: Made window key and visible")
        } catch {
            print("SceneDelegate: Error during setup: \(error)")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
