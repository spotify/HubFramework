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
    var hubFactory: HUBFactory!
    var hubComponentFallbackHandler: HUBComponentFallbackHandler!
    var hubViewControllerFactory = HUBSimpleViewControllerFactory()
    var defaultConfig: HUBConfig!
    var githubConfig: HUBConfig!

    let componentFallbackClosure = { (category: HUBComponentCategory) -> HUBComponent in
        if category == .card {
            return ImageComponent()
        }

        return RowComponent()
    }

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        self.window = window
        navigationController = NavigationController()

        hubFactory = HUBFactory()
        hubComponentFallbackHandler = hubFactory.createComponentFallbackHandler { category in
            if category == .card {
                return ImageComponent()
            }

            return RowComponent()
        }

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        setupDefaultConfig()
        setupGithubConfig()

        open(viewURI: .rootViewURI, animated: false)
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
//        hubManager.liveService?.stop()
    }
    
    // MARK: - HUBLiveServiceDelegate
    func liveService(_ liveService: HUBLiveService, didCreateContentOperation contentOperation: HUBContentOperation) {
        let viewController = hubManager.viewControllerFactory.createViewController(withContentOperations: [contentOperation],
                                                                                   featureTitle: "Live")

        prepareAndPush(viewController: viewController, animated: true)
    }

    // MARK: - Private

    private func setupDefaultConfig() {
        defaultConfig = HUBConfig.build(componentMargin: ComponentMargin, componentFallbackClosure: componentFallbackClosure,
                                        optionsClosure: nil)
        defaultConfig.componentRegistry.register(componentFactory: DefaultComponentFactory(), namespace: DefaultComponentFactory.namespace)

        defaultConfig.actionRegistry.register(TodoListActionFactory(), forNamespace: TodoListActionFactory.namespace)
    }

    private func setupGithubConfig() {
        let githubSchema = createGitHubSearchSchema()
        githubConfig = HUBConfig.build(componentMargin: ComponentMargin, componentFallbackClosure: componentFallbackClosure,
                                       optionsClosure: { options in
                                        options.jsonSchema = githubSchema
        })
        githubConfig.componentRegistry.register(componentFactory: DefaultComponentFactory(), namespace: DefaultComponentFactory.namespace)
    }

    /// Register the JSON schema for the GitHub search feature
    func createGitHubSearchSchema() -> HUBJSONSchema {
        let schema = hubFactory.createDefaultJSONSchema(with: hubComponentFallbackHandler, iconImageResolver: nil)

        schema.viewModelSchema.bodyComponentModelDictionariesPath = schema.createNewPath().go(to: "items").forEach().dictionaryPath()

        schema.componentModelSchema.targetDictionaryPath = schema.createNewPath().dictionaryPath()
        schema.componentModelSchema.titlePath = schema.createNewPath().go(to: "name").stringPath()
        schema.componentModelSchema.subtitlePath = schema.createNewPath().go(to: "owner").go(to: "login").run({ input in
            guard let authorName = input as? String else {
                return nil
            }

            return "Author: " + authorName
        }).stringPath()

        schema.componentTargetSchema.uriPath = schema.createNewPath().go(to: "html_url").urlPath()
        return schema
    }

    private func createViewController(viewURI: URL) -> HUBViewController? {
        if (HUBViewURIPredicate(viewURI: .stickyHeaderViewURI).evaluateViewURI(viewURI)) {
            return hubViewControllerFactory.createViewController(with: defaultConfig,
                                                                 contentOperations: [StickyHeaderContentOperation()],
                                                                 viewURI: viewURI,
                                                                 featureIdentifier: "stickyHeader",
                                                                 featureTitle: "Sticky Header")
        } else if (HUBViewURIPredicate(viewURI: .rootViewURI).evaluateViewURI(viewURI)) {
            return hubViewControllerFactory.createViewController(with: defaultConfig,
                                                                 contentOperations: [RootContentOperation()],
                                                                 viewURI: viewURI,
                                                                 featureIdentifier: "root",
                                                                 featureTitle: "Root feature")
        } else if (HUBViewURIPredicate(viewURI: .todoListViewURI).evaluateViewURI(viewURI)) {
            return hubViewControllerFactory.createViewController(with: defaultConfig,
                                                                 contentOperations: [TodoListContentOperation()],
                                                                 viewURI: viewURI,
                                                                 featureIdentifier: "todoList",
                                                                 featureTitle: "Todo List")
        } else if (HUBViewURIPredicate(viewURI: .prettyPicturesViewURI).evaluateViewURI(viewURI)) {
            return hubViewControllerFactory.createViewController(with: defaultConfig,
                                                                 contentOperations: [PrettyPicturesContentOperation()],
                                                                 viewURI: viewURI,
                                                                 featureIdentifier: "prettyPictures",
                                                                 featureTitle: "Pretty Pictures",
                                                                 actionHandler: PrettyPicturesActionHandler(),
                                                                 initialViewModel: nil)
        } else if (HUBViewURIPredicate(viewURI: .reallyLongListViewURI).evaluateViewURI(viewURI)) {
            return hubViewControllerFactory.createViewController(with: defaultConfig,
                                                                 contentOperations: [ReallyLongListContentOperation()],
                                                                 viewURI: viewURI,
                                                                 featureIdentifier: "reallyLongList",
                                                                 featureTitle: "Really Long List")
        } else if (HUBViewURIPredicate(viewURI: .gitHubSearchViewURI).evaluateViewURI(viewURI)) {
            let contentOperations: [HUBContentOperation] = [
                GitHubSearchBarContentOperation(),
                GitHubSearchResultsContentOperation(),
                GitHubSearchActivityIndicatorContentOperation()
            ]

            return hubViewControllerFactory.createViewController(with: githubConfig,
                                                                 contentOperations: contentOperations,
                                                                 viewURI: viewURI,
                                                                 featureIdentifier: "gitHubSearch",
                                                                 featureTitle: "GitHub Search")
        }
        return nil
    }

    private func startLiveService() {
        #if DEBUG
//        hubManager.liveService?.delegate = self
//        hubManager.liveService?.start(onPort: 7777)
        #endif
    }
    
    // MARK: - Opening view URIs

    @discardableResult private func open(viewURI: URL, animated: Bool) -> Bool {
        guard let viewController = createViewController(viewURI: viewURI) else {
            print("No view controller for URI \(viewURI)")
            return false
        }
        
        prepareAndPush(viewController: viewController, animated: animated)
        
        return true
    }
    
    // MARK: - View controller handling
    
    private func prepareAndPush(viewController: HUBViewController, animated: Bool) {
        viewController.delegate = navigationController
        viewController.view.backgroundColor = .white
        viewController.alwaysBounceVertical = (viewController.viewURI == URL.gitHubSearchViewURI)
        navigationController?.pushViewController(viewController, animated: animated)
    }
}

