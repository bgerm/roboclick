//
//  IndicatorWindow.m
//  RoboClick
//
//  Created by Bryan Germann on 6/6/12.
//  Copyright (c) 2012 Bryan Germann.
//  Licensed under the MIT License, see LICENSE.txt
//

#import "ClickIndicatorWindow.h"

@implementation ClickIndicatorWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation {
    self = [super initWithContentRect:contentRect styleMask:windowStyle backing:bufferingType defer:deferCreation];
    
    if (self) {
        [self setBackgroundColor: [NSColor clearColor]];
        [self setOpaque:NO];
        [self setLevel:1002];
        [self setCollectionBehavior:
                (NSWindowCollectionBehaviorCanJoinAllSpaces | 
                 NSWindowCollectionBehaviorStationary | 
                 NSWindowCollectionBehaviorIgnoresCycle)];
    }
    
    return self;
}

- (BOOL)canBecomeMainWindow {
    return false;
}

- (BOOL)canBecomeKeyWindow {
    return false;
}

- (BOOL)ignoresMouseEvents {
    return true;
}
@end
