//
//  ClickIndicatorView.m
//  RoboClick
//
//  Created by Bryan Germann on 6/6/12.
//  Copyright (c) 2012 Bryan Germann.
//  Licensed under the MIT License, see LICENSE.txt
//

#import <QuartzCore/QuartzCore.h>
#import "ClickIndicatorView.h"

@implementation ClickIndicatorView

@synthesize x, y, ring, ballRadius;

// Default animations for any keys we want to animate
+ (id)defaultAnimationForKey:(NSString *)key
{
	// animate the ring growing
    if ([key isEqualToString:@"ring"]) {
        CABasicAnimation *animation = [CABasicAnimation animation];
        [animation setDuration:0.01f];
        return animation;
    } else {
        // Defer to super's implementation for any keys we don't specifically handle.
        return [super defaultAnimationForKey:key];
    }
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib {
	self.x = NSMidX(self.bounds);
	self.y = NSMidY(self.bounds);
    
    self.ring = 2.0f;
    self.ballRadius = 5.0f;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect ballRect = NSMakeRect(x - ballRadius, y - ballRadius, ballRadius * 2.0, ballRadius * 2.0);
	NSBezierPath* ball = [NSBezierPath bezierPathWithOvalInRect:ballRect];
    [[NSColor colorWithCalibratedRed:0.7f green:0.0f blue:0.0f alpha:0.6f] setFill];
	[ball fill];

    NSColor *theColor = [NSColor colorWithCalibratedRed:0.8f green:0.1f blue:0.1f alpha:0.6f];    
    [theColor set];
    [ball setLineWidth:ring];
    [ball stroke]; 
}

- (void)setRing:(CGFloat)ringValue {
    ring = ringValue;
    [self setNeedsDisplay:YES];
}

- (void)setBallRadius:(CGFloat)ballRadiusValue {
    ballRadius = ballRadiusValue;
    [self setNeedsDisplay:YES];
}

- (BOOL)isOpaque {
	return NO;
}

@end
