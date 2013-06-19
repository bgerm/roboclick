//
//  ProcessInfo.m
//  RoboClick
//
//  Created by Bryan Germann on 6/6/12.
//  Copyright (c) 2012 Bryan Germann.
//  Licensed under the MIT License, see LICENSE.txt
//

#import "ProcessInfo.h"

@implementation ProcessInfo

@synthesize pid;
@synthesize appName;

-  (ProcessInfo*) initWithPid:(pid_t)p appName:(NSString *)name {
    self = [super init];
    
    if ( self ) {
        [self setPid: p andAppName: name];
    }
    
    return self;
}

- (void) setPid:(pid_t)p andAppName:(NSString *)name {
    pid = p;
    appName = name;
}

@end
