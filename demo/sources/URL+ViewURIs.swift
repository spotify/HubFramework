import Foundation

extension URL {
    /// The view URI used for the "Root" feature
    static var rootViewURI: URL {
        return URL(viewURI: "root")
    }
    
    // The view URI used for the "GitHub search" feature
    static var gitHubSearchViewURI: URL {
        return URL(viewURI: "githubsearch")
    }
}

private extension URL {
    init(viewURI: String) {
        self.init(string: "hub-demo:" + viewURI)!
    }
}
