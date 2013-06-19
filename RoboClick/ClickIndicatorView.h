//
//  ClickIndicatorView.h
//  RoboClick
//
//  Created by Bryan Germann on 6/6/12.
//  Copyright (c) 2012 Bryan Germann.
//  Licensed under the MIT License, see LICENSE.txt
//

#import <Cocoa/Cocoa.h>

@interface ClickIndicatorView : NSView
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) CGFloat ring;
@property (nonatomic) CGFloat ballRadius;
@end
