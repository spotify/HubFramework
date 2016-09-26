import UIKit
import HubFramework

/// The delegate of the application
@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navigationController: UINavigationController?
    var hubManager: HUBManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        self.window = window
        self.navigationController = UINavigationController()
        self.hubManager = self.makeHubManager()

        window.rootViewController = self.navigationController
        window.makeKeyAndVisible()
        
        self.registerAndOpenRootFeature()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.open(viewURI: url, animated: true)
    }
    
    // MARK: - Private
    
    private func makeHubManager() -> HUBManager {
        return HUBManager(
            connectivityStateResolver: ConnectivityStateResolver(),
            componentLayoutManager: ComponentLayoutManager(),
            componentFallbackHandler: ComponentFallbackHandler(),
            imageLoaderFactory: nil,
            iconImageResolver: nil,
            defaultActionHandler: nil,
            defaultContentReloadPolicy: nil,
            prependedContentOperationFactory: nil,
            appendedContentOperationFactory: nil
        )
    }
    
    private func registerAndOpenRootFeature() {
        self.hubManager?.featureRegistry.registerFeature(
            withIdentifier: "root",
            viewURIPredicate: HUBViewURIPredicate(viewURI: .rootViewURI),
            title: "Root feature",
            contentOperationFactories: [RootContentOperationFactory()],
            contentReloadPolicy: nil,
            customJSONSchemaIdentifier: nil,
            actionHandler: nil,
            viewControllerScrollHandler: nil
        )
        
        self.open(viewURI: .rootViewURI, animated: false)
    }
    
    @discardableResult private func open(viewURI: URL, animated: Bool) -> Bool {
        guard let viewController = self.hubManager?.viewControllerFactory.createViewController(forViewURI: viewURI) else {
            return false
        }
        
        viewController.view.backgroundColor = .white
        self.navigationController?.pushViewController(viewController, animated: animated)
        
        return true
    }
}

