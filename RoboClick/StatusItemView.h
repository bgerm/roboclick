//
//  StatusItemView.h
//  RoboClick
//
//  Created by Bryan Germann on 6/6/12.
//  Copyright (c) 2012 Bryan Germann.
//  Licensed under the MIT License, see LICENSE.txt
//

#import <AppKit/AppKit.h>

@interface StatusItemView : NSView <NSMenuDelegate> {
    NSStatusItem *statusItem;
    NSString *title;
    //NSImage *icon;
    NSButtonCell *buttonCell;
    BOOL imageState;
    BOOL isMenuVisible;
    BOOL isEnabled;
    
    SEL mouseDownSelector;
    SEL rightMouseDownSelector;
    id target;
}

@property (retain, nonatomic) NSStatusItem *statusItem;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) id target;
@property (nonatomic) SEL mouseDownSelector;
@property (nonatomic) SEL rightMouseDownSelector;

- (NSImage*)image;
- (void) setImage:(NSImage*)newIcon;
- (void) setEnabled:(BOOL)newEnabled;
- (BOOL) enabled;

- (void) setImageState:(BOOL)state;
- (BOOL) imageState;

@end