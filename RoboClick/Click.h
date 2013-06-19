//
//  Click.h
//  RoboClick
//
//  Created by Bryan Germann on 6/6/12.
//  Copyright (c) 2012 Bryan Germann.
//  Licensed under the MIT License, see LICENSE.txt
//

#import <Foundation/Foundation.h>

@interface Click : NSObject
+ (NSPoint)singleLeft;
+ (NSPoint)holdLeft;
+ (NSPoint)singleRight;
+ (NSPoint)holdRight;
+ (void)releaseLeft;
+ (void)releaseRight;
@end
