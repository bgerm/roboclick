//
//  StatusItemView.m
//  RoboClick
//
//  Created by Bryan Germann on 6/6/12.
//  Copyright (c) 2012 Bryan Germann.
//  Licensed under the MIT License, see LICENSE.txt
//
//  Note:  I thought it was ridiculous how much I needed to learn about
//         NSStatusItem and how it was drawn just to add text next to
//         it.  So, I found a blog describing how to do this and then some
//         uncopyrighted and unlicensed code that implemented this.
//         Combining those two resources, I've modified very little of it.
//         Blog:  http://undefinedvalue.com/2009/07/07/adding-custom-view-nsstatusitem

#import "StatusItemView.h"

#define StatusItemViewPaddingWidth 0
#define StatusItemViewPaddingHeight 3
#define StatusItemViewPaddingIconToText 0
#define StatusItemViewPaddingAfterText 3
#define AdditionalPadding 8

@implementation StatusItemView

@synthesize statusItem;
@synthesize target;
@synthesize mouseDownSelector;
@synthesize rightMouseDownSelector;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        statusItem = nil;
        title = nil;
        //icon=nil;
        isMenuVisible = NO;
        
        imageState = NO;
        buttonCell = [[NSButtonCell alloc] init];
        [buttonCell setBezelStyle:NSTexturedSquareBezelStyle];
        [buttonCell setButtonType:NSToggleButton];
    }
    return self;
}

- (void)mouseDown:(NSEvent *)event {
    if(mouseDownSelector != nil) {
        [target performSelectorOnMainThread:mouseDownSelector withObject:event waitUntilDone:YES];
    }
    
    [[self menu] setDelegate:self];
    [statusItem popUpStatusItemMenu:[self menu]];
    [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)event {
    if(rightMouseDownSelector != nil) {
        [target performSelectorOnMainThread:rightMouseDownSelector withObject:event waitUntilDone:YES];
    }
    
    [[self menu] setDelegate:self];
    [statusItem popUpStatusItemMenu:[self menu]];
    [self setNeedsDisplay:YES];
}

- (void) setEnabled:(BOOL)newEnabled {
    isEnabled=newEnabled;
    [self setNeedsDisplay:YES];
}

- (BOOL)enabled {
    return isEnabled;
}

- (void) setTarget:(id)newTarget {
    if (![newTarget isEqual:target]) {
        target=newTarget;
    }
}

- (void)menuWillOpen:(NSMenu *)menu {
    isMenuVisible = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    isMenuVisible = NO;
    [menu setDelegate:nil];
    [self setNeedsDisplay:YES];
}

- (NSColor *)titleForegroundColor {
    if (isMenuVisible) {
        return [NSColor whiteColor];
    } else   {
        return [NSColor blackColor];
    }
}

- (NSDictionary *)titleAttributes {
    // Use default menu bar font size
    NSFont *font = [NSFont menuBarFontOfSize:0];
    
    NSColor *foregroundColor = [self titleForegroundColor];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            foregroundColor, NSForegroundColorAttributeName,
            nil];
}

- (NSRect)titleBoundingRect {
    return [title boundingRectWithSize:NSMakeSize(1e100, 1e100)
                               options:0
                            attributes:[self titleAttributes]];
}

- (void) calculateWidth {
    int newWidth= 0;

    
    if (([title length] != 0) || ([buttonCell image]!=NULL)) {
        newWidth+=(2 * StatusItemViewPaddingWidth);
    }
    
    if (([title length] != 0) && ([buttonCell image]!=NULL))
        newWidth+=StatusItemViewPaddingIconToText;
    
    if ([title length] != 0) {
        newWidth += StatusItemViewPaddingAfterText;
        
        // Update status item size (which will also update this view's bounds)
        NSRect titleBounds = [self titleBoundingRect];
        newWidth += titleBounds.size.width;
    }
    
    if ([buttonCell image]!=NULL) {
        NSRect iconRect = [[buttonCell image] alignmentRect];
        newWidth += iconRect.size.width + AdditionalPadding;
    }
    
    [statusItem setLength:newWidth];
}

- (void)setTitle:(NSString *)newTitle {
    if (![title isEqual:newTitle]) {
        title = newTitle;
        [self calculateWidth];
        [self setNeedsDisplay:YES];
    }
}

- (NSString *)title {
    return title;
}

- (void)setImage:(NSImage*)newIcon {
    if (![newIcon isEqual:[buttonCell image]]) {
        [buttonCell setImage:newIcon];
        [self calculateWidth];
        [self setNeedsDisplay:YES];
    }
}

- (NSImage *)image {
    return [buttonCell image];
}

- (void)setImageState:(BOOL)state {
    NSInteger newState;
    
    if(state) {
        newState = NSOnState;
    } else   {
        newState = NSOffState;
    }
    
    if([buttonCell state] != newState) {
        [buttonCell setState:newState];
        [self calculateWidth];
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)imageState {
    return [buttonCell state] == NSOnState;
}

- (void)drawRect:(NSRect)rect {
    // Draw status bar background, highlighted if menu is showing
    [statusItem drawStatusBarBackgroundInRect:[self bounds]
                                withHighlight:isMenuVisible];
    
    int x=0;
    
    if (([buttonCell image]!=NULL) || ([title length] != 0)) {
        x=x+StatusItemViewPaddingWidth;
    }
    
    if ([buttonCell image]!=NULL) {
        NSRect alr = [[buttonCell image] alignmentRect];
        alr.size.width += AdditionalPadding;
        alr.size.height += 4;
        alr.origin.x += x;
        alr.origin.y -= 1;
        
        [buttonCell drawInteriorWithFrame:alr inView:self];
        x+=alr.size.width;
    }
    
    if (([buttonCell image]!=NULL) && ([title length] != 0)) {
        x=x+StatusItemViewPaddingIconToText;
    }
    
    if ([title length] != 0) {
        // Draw title string
        NSPoint origin = NSMakePoint(x,
                                     StatusItemViewPaddingHeight);
        [title drawAtPoint:origin
            withAttributes:[self titleAttributes]];
    }
}


@end