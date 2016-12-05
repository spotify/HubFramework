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
@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate, HUBLiveServiceDelegate {
    var window: UIWindow?
    var navigationController: NavigationController?
    var hubManager: HUBManager!
    
    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        self.window = window
        navigationController = NavigationController()
        
        hubManager = HUBManager(
            componentMargin: ComponentMargin,
            componentFallbackClosure: { category in
                if category == .card {
                    return ImageComponent()
                }
                
                return RowComponent()
            }
        )
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        registerDefaultComponentFactory()
        registerAndOpenRootFeature()
        registerGitHubSearchFeature()
        registerPrettyPicturesFeature()
        registerReallyLongListFeature()
        registerTodoListFeature()
        registerStickyHeaderFeature()
        startLiveService()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return open(viewURI: url, animated: true)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        startLiveService()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        hubManager.liveService?.stop()
    }
    
    // MARK: - HUBLiveServiceDelegate
    
    func liveService(_ liveService: HUBLiveService, didCreateViewController viewController: HUBViewController) {
        prepareAndPush(viewController: viewController, animated: true)
    }
    
    // MARK: - Private
    
    private func registerDefaultComponentFactory() {
        hubManager.componentRegistry.register(componentFactory: DefaultComponentFactory(), namespace: DefaultComponentFactory.namespace)
    }
    
    // MARK: - Feature registrations
    
    private func registerAndOpenRootFeature() {
        hubManager.featureRegistry.registerFeature(
            withIdentifier: "root",
            viewURIPredicate: HUBViewURIPredicate(viewURI: .rootViewURI),
            title: "Root feature",
            contentOperationFactories: [RootContentOperationFactory()],
            contentReloadPolicy: nil,
            customJSONSchemaIdentifier: nil,
            actionHandler: nil,
            viewControllerScrollHandler: nil
        )
        
        open(viewURI: .rootViewURI, animated: false)
    }
    
    private func registerGitHubSearchFeature() {
        hubManager.featureRegistry.registerFeature(
            withIdentifier: "gitHubSearch",
            viewURIPredicate: HUBViewURIPredicate(viewURI: .gitHubSearchViewURI),
            title: "GitHub Search",
            contentOperationFactories: [GitHubSearchContentOperationFactory()],
            contentReloadPolicy: nil,
            customJSONSchemaIdentifier: hubManager.jsonSchemaRegistry.gitHubSearchSchemaIdentifier,
            actionHandler: nil,
            viewControllerScrollHandler: nil
        )
        
        hubManager.jsonSchemaRegistry.registerGitHubSearchSchema()
    }
    
    private func registerPrettyPicturesFeature() {
        hubManager.featureRegistry.registerFeature(
            withIdentifier: "prettyPictures",
            viewURIPredicate: HUBViewURIPredicate(viewURI: .prettyPicturesViewURI),
            title: "Pretty Pictures",
            contentOperationFactories: [PrettyPicturesContentOperationFactory()],
            contentReloadPolicy: nil,
            customJSONSchemaIdentifier: nil,
            actionHandler: PrettyPicturesActionHandler(),
            viewControllerScrollHandler: nil
        )
    }
    
    private func registerReallyLongListFeature() {
        hubManager.featureRegistry.registerFeature(
            withIdentifier: "reallyLongList",
            viewURIPredicate: HUBViewURIPredicate(viewURI: .reallyLongListViewURI),
            title: "Really Long List",
            contentOperationFactories: [ReallyLongListContentOperationFactory()],
            contentReloadPolicy: nil,
            customJSONSchemaIdentifier: nil,
            actionHandler: nil,
            viewControllerScrollHandler: nil
        )
    }
    
    private func registerTodoListFeature() {
        let contentOperationFactory = HUBBlockContentOperationFactory() { _ in
            return [TodoListContentOperation()]
        }
        
        hubManager.featureRegistry.registerFeature(
            withIdentifier: "todoList",
            viewURIPredicate: HUBViewURIPredicate(viewURI: .todoListViewURI),
            title: "Todo List",
            contentOperationFactories: [contentOperationFactory],
            contentReloadPolicy: nil,
            customJSONSchemaIdentifier: nil,
            actionHandler: nil,
            viewControllerScrollHandler: nil
        )
        
        hubManager.actionRegistry.register(TodoListActionFactory(), forNamespace: TodoListActionFactory.namespace)
    }
    
    private func registerStickyHeaderFeature() {
        let contentOperationFactory = HUBBlockContentOperationFactory() { _ in
            return [StickyHeaderContentOperation()]
        }
        
        hubManager.featureRegistry.registerFeature(
            withIdentifier: "stickyHeader",
            viewURIPredicate: HUBViewURIPredicate(viewURI: .stickyHeaderViewURI),
            title: "Sticky Header",
            contentOperationFactories: [contentOperationFactory],
            contentReloadPolicy: nil,
            customJSONSchemaIdentifier: nil,
            actionHandler: nil,
            viewControllerScrollHandler: nil
        )
    }
    
    private func startLiveService() {
        #if DEBUG
        hubManager.liveService?.delegate = self
        hubManager.liveService?.start(onPort: 7777)
        #endif
    }
    
    // MARK: - Opening view URIs
    
    @discardableResult private func open(viewURI: URL, animated: Bool) -> Bool {
        guard let viewController = hubManager?.viewControllerFactory.createViewController(forViewURI: viewURI) else {
            return false
        }
        
        prepareAndPush(viewController: viewController, animated: animated)
        
        return true
    }
    
    // MARK: - View controller handling
    
    private func prepareAndPush(viewController: HUBViewController, animated: Bool) {
        viewController.delegate = navigationController
        viewController.view.backgroundColor = .white
        navigationController?.pushViewController(viewController, animated: animated)
    }
}

