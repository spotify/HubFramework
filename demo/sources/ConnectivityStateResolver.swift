import Foundation
import HubFramework

/// Connectivity state resolver used when setting up HUBManager
class ConnectivityStateResolver: NSObject, HUBConnectivityStateResolver {
    private let observers = NSHashTable<HUBConnectivityStateResolverObserver>.weakObjects()
    
    func resolveConnectivityState() -> HUBConnectivityState {
        return .online
    }
    
    func add(observer: HUBConnectivityStateResolverObserver) {
        self.observers.add(observer)
    }
    
    func remove(observer: HUBConnectivityStateResolverObserver) {
        self.observers.remove(observer)
    }
}
