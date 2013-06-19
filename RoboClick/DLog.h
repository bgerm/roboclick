//
//  DLog.h
//  RoboClick
//
//  Created by Bryan Germann on 6/6/12.
//  Copyright (c) 2012 Bryan Germann.
//  Licensed under the MIT License, see LICENSE.txt
//

#ifdef DEBUG
#	define DebugLog(format, ...) NSLog(@"<Debug>: " format @" [" __FILE__ @":%i]", ##__VA_ARGS__, __LINE__)
#	define InfoLog(format, ...) NSLog(@"<Info> " format @" [" __FILE__ @":%i]", ##__VA_ARGS__, __LINE__)
#	define WarningLog(format, ...) NSLog(@"<Warning> " format @" [" __FILE__ @":%i]", ##__VA_ARGS__, __LINE__)
#	define ErrorLog(format, ...) NSLog(@"<Error> " format @" [" __FILE__ @":%i]", ##__VA_ARGS__, __LINE__)
#else
#	define DebugLog(format, ...)
#	define InfoLog(format, ...) NSLog(@"<Info>: " format, ##__VA_ARGS__)
#	define WarningLog(format, ...) NSLog(@"<Warning>: " format, ##__VA_ARGS__)
#	define ErrorLog(format, ...) NSLog(@"<Error>: " format, ##__VA_ARGS__)
#endif