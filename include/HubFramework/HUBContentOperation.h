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

#import "HUBConnectivityState.h"

@protocol HUBContentOperation;
@protocol HUBViewModelBuilder;
@protocol HUBFeatureInfo;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - HUBContentOperationDelegate

/**
 *  Delegate protocol for objects conforming to `HUBContentOperation`
 *
 *  You don't conform to this protocol yourself. Instead, you synthesize your content operation's `delegate`
 *  property, which the Hub Framework will assign. You may then use the methods defined in this protocol to
 *  communicate content operation events back to the framework.
 */
@protocol HUBContentOperationDelegate <NSObject>

/**
 *  Notify the Hub Framework that a content operation finished
 *
 *  @param operation The operation that finished
 *
 *  All operations are required to either call this method, or the one that signals a failure, to notify the
 *  framework of its outcome. Note that this method can only be called once per execution - multiple calls will
 *  be ignored. To be able to update the operation's state - first call `-contentOperationRequiresRescheduling:`
 *  to get the Hub Framework to reschedule and re-execute the operation.
 */
- (void)contentOperationDidFinish:(id<HUBContentOperation>)operation;

/**
 *  Notify the Hub Framework that a content operation failed because of an error
 *
 *  @param operation The operation that encountered an error
 *  @param error The error that was encountered
 *
 *  Use this method to propagate an error from a content operation to the framework. If this method is called, an
 *  attempt will be made to recover by sending the error when calling any next content operation in the sequence as
 *  `previousContentOperationError`. If the next content operation manages to recover, the error is silenced. If no
 *  additional content operations were able to recover, the error will block the creation of a view model and a
 *  visual representation of it will be rendered instead of content.
 */
- (void)contentOperation:(id<HUBContentOperation>)operation didFailWithError:(NSError *)error;

/**
 *  Notify the Hub Framework that a content operation requires rescheduling
 *
 *  @param operation The operation that requires rescheduling
 *
 *  Use this method to get an operation to be re-executed by the framework, to be able to react to changes in any
 *  underlying data model or after a certain period of time has passed. When this is called, the framework will put
 *  the operation - as well as any subsequent operations after it in the content loading chain - in its content loading
 *  queue, and will execute it as soon as possible.
 */
- (void)contentOperationRequiresRescheduling:(id<HUBContentOperation>)operation;

@end

#pragma mark - HUBContentOperation

/**
 *  Protocol used to define objects that load content that will make up a Hub Framework view model
 *
 *  To define a content operation, conform to this protocol in a custom object - and return it from a matching
 *  `HUBContentOperationFactory` that is passed when configuring your feature with the Hub Framework. A content
 *  operation is free to do its work in whatever way it desires, online or offline - manipulating a view's content
 *  either in code or through JSON (or another data format) - synchronously or asynchronously.
 *
 *  When a new view is about to be displayed by the Hub Framework, the framework will call the content operations
 *  associated with that view. The content that these content operations add to the used `HUBViewModelBuilder` will
 *  then be used to create a view model for the view.
 *
 *  If your content operation also has some initial content that can be synchronously added to the view, before the
 *  main content loading chain is started - it can conform to `HUBContentOperationWithInitialContent` to be able to
 *  do so.
 */
@protocol HUBContentOperation <NSObject>

/// The content operation's delegate. Don't assign this property yourself, it will be set by the Hub Framework.
@property (nonatomic, weak, nullable) id<HUBContentOperationDelegate> delegate;


/**
 *  Perform the operation for a view with a certain view URI
 *
 *  @param viewURI The URI of the view that the content operation is being used in
 *  @param featureInfo An object containing information about the feature that the operation is being used in
 *  @param connectivityState The current connectivity state, as resolved by `HUBConnectivityStateResolver`
 *  @param viewModelBuilder The builder that can be used to add, change or remove content to/from the view
 *  @param previousError Any error encountered by a previous content operation in the view's content loading chain.
 *         If this is non-`nil`, you can attempt to recover the error in this content operation, to provide any relevant
 *         content to avoid displaying an error screen for the user. In case this content operation can't recover the error,
 *         it should propagate the error using the error delegate callback method.
 *
 *  The operation should perform any work to add, change or remove content to/from the view, and then call its delegate once
 *  done (either using the success or failure method). If the operation cannot perform any work at this point, it still needs
 *  to call the delegate to make the content loading chain progress.
 */
- (void)performForViewURI:(NSURL *)viewURI
              featureInfo:(id<HUBFeatureInfo>)featureInfo
        connectivityState:(HUBConnectivityState)connectivityState
         viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
            previousError:(nullable NSError *)previousError;

@end

NS_ASSUME_NONNULL_END
