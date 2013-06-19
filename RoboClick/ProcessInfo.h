//
//  ProcessInfo.h
//  RoboClick
//
//  Created by Bryan Germann on 6/6/12.
//  Copyright (c) 2012 Bryan Germann.
//  Licensed under the MIT License, see LICENSE.txt
//

#import <Foundation/Foundation.h>

@interface ProcessInfo : NSObject

- (void) setPid:(pid_t)p andAppName:(NSString *)name;
- (ProcessInfo*) initWithPid: (pid_t)p appName: (NSString *)name;

@property (copy) NSString *appName;
@property pid_t pid;

@end
