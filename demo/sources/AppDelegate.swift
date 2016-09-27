/*
 *  Copyright (c) 2016 Spotify AB.
 *
 *  Licensed to the Apache Software Foundation (ASF) under one
 *  or more contributor license agreements.  See the NOTICE file
 *  distributed with this work for additional information
 *  regarding copyright ownership.  The ASF licenses this file
 *  to you under the Apache License, Version 2.0 (the
 *  "License"); you may not use this file except in compliance
 *  with the License.  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

import UIKit
import HubFramework

/// The delegate of the application
@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navigationController: UINavigationController?
    var hubManager: HUBManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        self.window = window
        self.navigationController = UINavigationController()
        self.hubManager = self.makeHubManager()

        window.rootViewController = self.navigationController
        window.makeKeyAndVisible()
        
        self.registerDefaultComponentFactory()
        self.registerAndOpenRootFeature()
        self.registerGitHubSearchFeature()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.open(viewURI: url, animated: true)
    }
    
    // MARK: - Private
    
    private func makeHubManager() -> HUBManager {
        return HUBManager(
            componentLayoutManager: ComponentLayoutManager(),
            componentFallbackHandler: ComponentFallbackHandler(),
            connectivityStateResolver: nil,
            imageLoaderFactory: nil,
            iconImageResolver: nil,
            defaultActionHandler: nil,
            defaultContentReloadPolicy: nil,
            prependedContentOperationFactory: nil,
            appendedContentOperationFactory: nil
        )
    }
    
    private func registerDefaultComponentFactory() {
        self.hubManager.componentRegistry.register(componentFactory: DefaultComponentFactory(), namespace: DefaultComponentFactory.namespace)
    }
    
    private func registerAndOpenRootFeature() {
        self.hubManager.featureRegistry.registerFeature(
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
    
    private func registerGitHubSearchFeature() {
        self.hubManager.featureRegistry.registerFeature(
            withIdentifier: "gitHubSearch",
            viewURIPredicate: HUBViewURIPredicate(viewURI: .gitHubSearchViewURI),
            title: "GitHub Search",
            contentOperationFactories: [GitHubSearchContentOperationFactory()],
            contentReloadPolicy: nil,
            customJSONSchemaIdentifier: self.hubManager.jsonSchemaRegistry.gitHubSearchSchemaIdentifier,
            actionHandler: nil,
            viewControllerScrollHandler: nil
        )
        
        self.hubManager.jsonSchemaRegistry.registerGitHubSearchSchema()
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

