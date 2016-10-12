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

#import "HUBMoveIndexPath.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBMoveIndexPath

- (instancetype)initWithFrom:(NSIndexPath *)fromIndexPath
                          to:(NSIndexPath *)toIndexPath
{
    self = [super init];
    if (self) {
        _fromIndexPath = fromIndexPath;
        _toIndexPath = toIndexPath;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[HUBMoveIndexPath class]]) {
        HUBMoveIndexPath *otherIndexPath = (HUBMoveIndexPath *)object;
        return [otherIndexPath.fromIndexPath isEqual:self.fromIndexPath] &&
            [otherIndexPath.toIndexPath isEqual:self.toIndexPath];
    }

    return NO;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"\t{\n\
        from: %@\n\
        to: %@\n\
    \t}", self.fromIndexPath, self.toIndexPath];
}

@end

NS_ASSUME_NONNULL_END
