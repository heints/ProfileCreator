//
//  PFPPayloadExporter.h
//  ProfilePayloads
//
//  Created by Erik Berglund.
//  Copyright (c) 2016 ProfileCreator. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <Cocoa/Cocoa.h>
@class PFPPayloadCollections;
@class PFPPayloadSettings;

@interface PFPPayloadExporter : NSObject

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithPayloadCollections:(PFPPayloadCollections *_Nonnull)payloadCollections
                                   payloadSettings:(PFPPayloadSettings *_Nonnull)payloadSettings
                                    baseIdentifier:(NSString *_Nonnull)baseIdentifier
                                             scope:(PFPScope)scope
                                      distribution:(PFPDistribution)distribution
                                        supervised:(BOOL)supervised
                                       profileUUID:(NSString *_Nonnull)profileUUID
                                    profileVersion:(NSInteger)profileVersion;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instance Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *_Nullable)profileWithSettings:(NSDictionary *_Nonnull)payloadSettings error:(NSError *_Nullable *_Nullable)error;

@end
