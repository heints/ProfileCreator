//
//  PFCPreferencesToolbarItemGeneral.m
//  ProfileCreator
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

#import "PFCPreferences.h"
#import "PFCPreferencesToolbarItemGeneral.h"

NSString *_Nonnull const PFCPreferencesToolbarItemIdentifierGeneral = @"General";

@interface PFCPreferencesToolbarItemGeneral ()
@property (nonatomic, strong, readwrite, nonnull) NSToolbarItem *toolbarItem;
@end

@implementation PFCPreferencesToolbarItemGeneral

- (nullable instancetype)initWithSender:(id _Nonnull)sender {
    self = [super initWithNibName:@"PFCPreferencesToolbarItemGeneral" bundle:nil];
    if (self != nil) {

        NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:PFCPreferencesToolbarItemIdentifierGeneral];
        [toolbarItem setImage:[NSImage imageNamed:NSImageNamePreferencesGeneral]];
        [toolbarItem setLabel:PFCPreferencesToolbarItemIdentifierGeneral];
        [toolbarItem setPaletteLabel:PFCPreferencesToolbarItemIdentifierGeneral];
        [toolbarItem setTarget:sender];
        [toolbarItem setAction:@selector(selectedToolbarItem:)];

        _toolbarItem = toolbarItem;
    }
    return self;
}

@end
