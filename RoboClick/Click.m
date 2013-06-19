//
//  Click.m
//  RoboClick
//
//  Created by Bryan Germann on 6/6/12.
//  Copyright (c) 2012 Bryan Germann.
//  Licensed under the MIT License, see LICENSE.txt
//

#import "Click.h"

@implementation Click

+ (NSPoint)singleLeft {
    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint mouseLocation = CGEventGetLocation(ourEvent);
    
    /* The mouse location that we return, which is used for drawing the click indicator
     * Here we grab the mouse location again, but in cocoa screen coordinates.
     * This is unfortunate, but it's probably quicker and safer (with multiple monitors and
     * resolutions) to just grab again than make our own conversions.
     */
    NSPoint nsMouseLocation = [NSEvent mouseLocation];
    
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, mouseLocation, kCGMouseButtonLeft);
    
    CGEventSetType(theEvent, kCGEventLeftMouseDown);  
    CGEventPost(kCGHIDEventTap, theEvent);  
    
    CGEventSetType(theEvent, kCGEventLeftMouseUp); 
    CGEventPost(kCGHIDEventTap, theEvent); 
    
    CFRelease(theEvent); 
       
    return nsMouseLocation;
}

+ (NSPoint)holdLeft {
    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint mouseLocation = CGEventGetLocation(ourEvent);
    
    /* The mouse location that we return, which is used for drawing the click indicator
     * Here we grab the mouse location again, but in cocoa screen coordinates.
     * This is unfortunate, but it's probably quicker and safer (with multiple monitors and
     * resolutions) to just grab again than make our own conversions.
     */
    NSPoint nsMouseLocation = [NSEvent mouseLocation];
    
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, mouseLocation, kCGMouseButtonLeft);
    
    CGEventSetType(theEvent, kCGEventLeftMouseDown);  
    CGEventPost(kCGHIDEventTap, theEvent);  
    
    CFRelease(theEvent);
    
    return nsMouseLocation;
}

+ (void)releaseLeft {
    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint mouseLocation = CGEventGetLocation(ourEvent);
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, mouseLocation, kCGMouseButtonLeft);
    
    CGEventSetType(theEvent, kCGEventLeftMouseUp);  
    CGEventPost(kCGHIDEventTap, theEvent);  
    
    CFRelease(theEvent); 
}

+ (NSPoint)singleRight {
    CGEventRef ourEvent = CGEventCreate(NULL);
    
    CGPoint mouseLocation = CGEventGetLocation(ourEvent);
    
    /* The mouse location that we return, which is used for drawing the click indicator
     * Here we grab the mouse location again, but in cocoa screen coordinates.
     * This is unfortunate, but it's probably quicker and safer (with multiple monitors and
     * resolutions) to just grab again than make our own conversions.
     */
    NSPoint nsMouseLocation = [NSEvent mouseLocation];
    
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventRightMouseDown, mouseLocation, kCGMouseButtonRight);
    
    CGEventSetType(theEvent, kCGEventRightMouseDown);  
    CGEventPost(kCGHIDEventTap, theEvent);  
    
    CGEventSetType(theEvent, kCGEventRightMouseUp); 
    CGEventPost(kCGHIDEventTap, theEvent); 
    
    CFRelease(theEvent); 
    
    return nsMouseLocation;
}

+ (NSPoint)holdRight {
    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint mouseLocation = CGEventGetLocation(ourEvent);
    
    
    /* The mouse location that we return, which is used for drawing the click indicator
     * Here we grab the mouse location again, but in cocoa screen coordinates.
     * This is unfortunate, but it's probably quicker and safer (with multiple monitors and
     * resolutions) to just grab again than make our own conversions.
     */
    NSPoint nsMouseLocation = [NSEvent mouseLocation];
    
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventRightMouseDown, mouseLocation, kCGMouseButtonRight);
    
    CGEventSetType(theEvent, kCGEventRightMouseDown);  
    CGEventPost(kCGHIDEventTap, theEvent);  
    
    CFRelease(theEvent); 
    
    return nsMouseLocation;
}

+ (void)releaseRight {
    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint mouseLocation = CGEventGetLocation(ourEvent);
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventRightMouseUp, mouseLocation, kCGMouseButtonRight);
    
    CGEventSetType(theEvent, kCGEventRightMouseUp);  
    CGEventPost(kCGHIDEventTap, theEvent);  
    
    CFRelease(theEvent); 
}

@end
