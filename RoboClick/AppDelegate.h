//
//  AppDelegate.h
//  RoboClick
//
//  Created by Bryan Germann on 6/6/12.
//  Copyright (c) 2012 Bryan Germann.
//  Licensed under the MIT License, see LICENSE.txt

#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/ShortcutRecorder.h>
#import "SGHotKey.h"
#import "StatusItemView.h"
#import "ProcessInfo.h"
#import "ClickIndicatorWindow.h"
#import "ClickIndicatorView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    ClickIndicatorWindow *indicatorWindow;
    ClickIndicatorView *clickIndicatorView;
        
    NSInteger leftRepeatInterval;
    IBOutlet SRRecorderControl *leftRepeatRecorder;
    IBOutlet SRRecorderControl *leftHoldRecorder;
    IBOutlet NSSlider *leftRepeatIntervalSlider;
    IBOutlet NSTextField *leftRepeatIntervalLabel;
    
    NSInteger rightRepeatInterval;
    IBOutlet SRRecorderControl *rightRepeatRecorder;
    IBOutlet SRRecorderControl *rightHoldRecorder;
    IBOutlet NSSlider *rightRepeatIntervalSlider;
    IBOutlet NSTextField *rightRepeatIntervalLabel;

    IBOutlet NSImageView *imageView;
    NSTimer *repeatClickTimer;
    NSStatusItem *roboclickStatusItem;
    
    NSImage *statusImage;   
    NSImage *statusImageHoldLeft;
    NSImage *statusImageHoldRight;
    NSImage *statusImageRepeatLeft;
    NSImage *statusImageRepeatRight;
    
    StatusItemView *view;
    
    pid_t repeatPid;
}

typedef enum {
    None,
    LeftRepeat,
    LeftHold,
    RightHold,
    RightRepat
} RoboAction;

- (void)setupShortcutRecorder:(SRRecorderControl*)shortcutRecorder;
- (void)setupShortcutRecorders;
- (void)updateHotKey:(SRRecorderControl*)shortcutRecorder;
- (void)updateHotKeys;
- (void)stopRepeatClick;
- (void)leftSliderDelegate:(NSSlider*)sender;
- (void)rightSliderDelegate:(NSSlider*)sender;
- (IBAction)showAbout:(id)sender;
- (IBAction)showPreferences:(id)sender;
- (void)toggleRepeatLeftClick;
- (void)toggleRepeatRightClick;
- (void)toggleHoldLeftClick;
- (void)toggleHoldRightClick;
- (void)repeatedLeftClick:(NSTimer*)timer;
- (void)repeatedRightClick:(NSTimer*)timer;
- (IBAction)beginEventMonitor;
- (void)iconOff;
- (void)resetState;
- (IBAction)showWelcomeMessage;
- (IBAction)setupMenu:(NSImage *)sImage;
- (void)resetStateOnEventType:(NSEvent*)incomingEvent;
- (ProcessInfo *)processInfoUnderMouse:(NSPoint) mouse;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet ClickIndicatorWindow *clickIndicatorWindow;
@property (assign) IBOutlet ClickIndicatorView *clickIndicatorView;
@property (assign) int ringIncrementor;

@property NSInteger leftRepeatInterval;
@property (retain) IBOutlet SRRecorderControl *leftRepeatRecorder;
@property (retain) IBOutlet SRRecorderControl *leftHoldRecorder;
@property (retain) IBOutlet NSSlider *leftRepeatIntervalSlider;
@property (retain) IBOutlet NSTextField *leftRepeatIntervalLabel;

@property NSInteger rightRepeatInterval;
@property (retain) IBOutlet SRRecorderControl *rightRepeatRecorder;
@property (retain) IBOutlet SRRecorderControl *rightHoldRecorder;
@property (retain) IBOutlet NSSlider *rightRepeatIntervalSlider;
@property (retain) IBOutlet NSTextField *rightRepeatIntervalLabel;

@property (retain) NSTimer *repeatClickTimer;
@property RoboAction roboAction;

@property (retain) NSStatusItem *roboclickStatusItem;
@property (retain) StatusItemView *view;

@property pid_t repeatPid;

@end
