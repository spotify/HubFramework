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

#import "HUBCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBCollectionView ()
@property (nonatomic, strong, readonly) NSMutableSet<NSString *> *registeredCollectionViewCellReuseIdentifiers;
@end

@implementation HUBCollectionView
@synthesize registeredCollectionViewCellReuseIdentifiers = _registeredCollectionViewCellReuseIdentifiers;
@dynamic delegate;

- (void)setContentOffset:(CGPoint)contentOffset
{
    id<HUBCollectionViewDelegate> const delegate = self.delegate;
    
    if (delegate != nil) {
        if (![delegate collectionViewShouldBeginScrolling:self]) {
            self.panGestureRecognizer.enabled = NO;
            self.panGestureRecognizer.enabled = YES;
            return;
        }
    }
    
    [super setContentOffset:contentOffset];
}

- (NSMutableSet<NSString *> *)registeredCollectionViewCellReuseIdentifiers
{
    if (!_registeredCollectionViewCellReuseIdentifiers) {
        _registeredCollectionViewCellReuseIdentifiers = [NSMutableSet new];
    }

    return _registeredCollectionViewCellReuseIdentifiers;
}

- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier
                                                             forIndexPath:(NSIndexPath *)indexPath
                                                cellClassWhenUnregistered:(Class)cellClass
{
    if (![self.registeredCollectionViewCellReuseIdentifiers containsObject:identifier]) {
        [self registerClass:cellClass forCellWithReuseIdentifier:identifier];
    }

    return [self dequeueReusableCellWithReuseIdentifier:identifier
                                           forIndexPath:indexPath];
}

@end

NS_ASSUME_NONNULL_END
