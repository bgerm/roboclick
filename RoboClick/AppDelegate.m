//
//  AppDelegate.m
//  RoboClick
//
//  Created by Bryan Germann on 6/6/12.
//  Copyright (c) 2012 Bryan Germann.
//  Licensed under the MIT License, see LICENSE.txt
//

#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "SGHotKeyCenter.h"
#import "Click.h"
#import "DLog.h"
#import "StatusItemView.h"
#import "ProcessInfo.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize repeatClickTimer;
@synthesize leftRepeatInterval;
@synthesize leftRepeatRecorder;
@synthesize leftHoldRecorder;
@synthesize leftRepeatIntervalSlider;
@synthesize leftRepeatIntervalLabel;
@synthesize rightRepeatInterval;
@synthesize rightRepeatRecorder;
@synthesize rightHoldRecorder;
@synthesize rightRepeatIntervalSlider;
@synthesize rightRepeatIntervalLabel;
@synthesize roboAction;
@synthesize roboclickStatusItem;
@synthesize view;
@synthesize repeatPid;
@synthesize clickIndicatorWindow = _indicatorWindow;
@synthesize clickIndicatorView = _clickIndicatorView;
@synthesize ringIncrementor;

/* Initialize application */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {      
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
                                    [NSNumber numberWithInt:8], @"leftRepeatInterval", 
                                    [NSNumber numberWithInt:8], @"rightRepeatInterval",
                                    [NSNumber numberWithBool:YES], @"bindRepeatsToPid",
                                    [NSNumber numberWithBool:YES], @"showClickIndicator",
                                    [NSNumber numberWithBool:NO], @"suppressWelcomeDefault", nil];
    [defaults registerDefaults:appDefaults];
    
    self.rightRepeatInterval = [defaults integerForKey:@"rightRepeatInterval"];
    self.leftRepeatInterval = [defaults integerForKey:@"leftRepeatInterval"];

    [self setupShortcutRecorders];
    [self updateHotKeys];
    
    [[self leftRepeatIntervalSlider] setAction:@selector(leftSliderDelegate:)];
    [[self rightRepeatIntervalSlider] setAction:@selector(rightSliderDelegate:)];
    
    self.roboAction = None;
    
    // setup status item icons
    NSBundle *bundle = [NSBundle mainBundle];
    
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"status_item_normal" ofType:@"png"]];
    statusImageHoldLeft = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"status_item_hold_left" ofType:@"png"]];
    statusImageHoldRight = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"status_item_hold_right" ofType:@"png"]];
    statusImageRepeatLeft = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"status_item_repeat_left" ofType:@"png"]];
    statusImageRepeatRight = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"status_item_repeat_right" ofType:@"png"]];
    
    [self setupMenu: statusImage];
    
    /* Set the preferences header icon from the app icon */
    NSImage *imageFromIcon = [NSApp applicationIconImage];
    [imageView setImage: imageFromIcon]; 
    
    [self beginEventMonitor];

    [self showWelcomeMessage];
}

/* Handle status item clicks by reseting the state of the
 * app and stopping the repeat timer 
 */
- (void)statusItemClicked:(id)sender {
    InfoLog(@"StatusItem clicked.  Reseting...");
    [repeatClickTimer invalidate];
    [self resetState];
}

/* Setup StatusItem and its menu */
- (IBAction)setupMenu:(NSImage *)sImage {
    self.roboclickStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    view = [[StatusItemView alloc] init];
    [self.view setStatusItem:self.roboclickStatusItem];
    [self.view setTarget:self];
    [self.view setImage:sImage];
    [self.view setImageState:NO];
    [self.view setMouseDownSelector:@selector(statusItemClicked:)];
    [self.view setRightMouseDownSelector:@selector(statusItemClicked:)];
   
    NSMenu *roboclickCursorMenu = [[NSMenu alloc] init];
    
    NSMenuItem *aboutMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"About", nil) action:@selector(showAbout:) keyEquivalent:@""];
	[aboutMenuItem setTarget:self];
	[roboclickCursorMenu addItem:aboutMenuItem];
    
    NSMenuItem *preferencesMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Preferences", nil) action:@selector(showPreferences:) keyEquivalent:@""];
	[aboutMenuItem setTarget:self];
	[roboclickCursorMenu addItem:preferencesMenuItem];
    
    [roboclickCursorMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *quitMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Quit", nil) action:@selector(terminate:) keyEquivalent:@""];
	[quitMenuItem setTarget:NSApp];
	[roboclickCursorMenu addItem:quitMenuItem];
	
    [self.view setMenu:roboclickCursorMenu];
    
    [self.roboclickStatusItem setView:self.view];
}

/* Popup alert message informing user how things work.
 * Allow user to not show it again by setting a surpress variable in 
 * UserDefaults
 */
- (IBAction)showWelcomeMessage {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if (![userDefaults boolForKey:@"suppressWelcomeDefault"]) {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Welcome to RoboClick", nil)
										 defaultButton:NSLocalizedString(@"OK", nil)
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"RoboClick runs in the OS X menu bar.\n\nAuto clicking is controlled by the hot keys you assign in the preferences.", nil)];
		[alert setShowsSuppressionButton:YES];
		[alert runModal];
		if ([[alert suppressionButton] state] == NSOnState) {
            [userDefaults setBool:YES forKey:@"suppressWelcomeDefault"];
		}
	}
}

- (void)resetStateOnEventType:(NSEvent*)incomingEvent {
    if (self.roboAction == RightHold && [incomingEvent type] == NSRightMouseUp) {
        self.roboAction = None;
        [self resetState];
    } else if (self.roboAction == LeftHold && [incomingEvent type] == NSLeftMouseUp) {
        self.roboAction = None;
        [self resetState];
    }
}

/* Sets up global and local monitors for left and right mouse up events
 * to reset the state of the app.  We do this because we are holding down
 * a click.  If the person decides to click their mouse and a mouse up event
 * occurs, then we need to capture that to reset the state to being no longer
 * in hold click mode.
 */
- (IBAction)beginEventMonitor {
    [NSEvent addGlobalMonitorForEventsMatchingMask:(NSLeftMouseUpMask | NSRightMouseUpMask) handler:^(NSEvent *incomingEvent) {
        [self resetStateOnEventType: incomingEvent];
        
    }];
    
    [NSEvent addLocalMonitorForEventsMatchingMask:(NSLeftMouseUpMask | NSRightMouseUpMask) handler:^(NSEvent *incomingEvent)  { 
        NSEvent *result = incomingEvent;
        
        [self resetStateOnEventType: incomingEvent];
        
        return result;
    }];
}


- (IBAction)showAbout:(id)sender {
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:sender];
}

- (IBAction)showPreferences:(id)sender {
	[self.window center];
	[self.window makeKeyAndOrderFront:sender];
}

- (void)resetState {
    if (self.roboAction == LeftHold) {
        InfoLog(@"releaseLeft");
        [Click releaseLeft];
    }
    
    if (self.roboAction == RightHold) {
        InfoLog(@"releaseRight");
        [Click releaseRight];
    }
    
    [self iconOff];
    self.roboAction = None;
    [self.clickIndicatorWindow orderOut:nil]; // hide the clickIndicatorWindow
}

- (void)setupShortcutRecorders {
    [self setupShortcutRecorder: leftRepeatRecorder];
    [self setupShortcutRecorder: leftHoldRecorder];
    [self setupShortcutRecorder: rightRepeatRecorder];
    [self setupShortcutRecorder: rightHoldRecorder];    
}

/* Defines some shortcutRecord settings and updates the recorder's placeholder w/ the
 * hotkey stored in their user defaults.
 */
- (void)setupShortcutRecorder:(SRRecorderControl*)shortcutRecorder {
    [shortcutRecorder setCanCaptureGlobalHotKeys:YES];
    [shortcutRecorder setDelegate:self];
    
    NSString *hotkeyName = shortcutRecorder.identifier;
    
    id keyComboPlist = [[NSUserDefaults standardUserDefaults] objectForKey:hotkeyName];
    SGKeyCombo *keyCombo = [[SGKeyCombo alloc] initWithPlistRepresentation:keyComboPlist];
    SGHotKey *hotKey = [[SGHotKey alloc] initWithIdentifier:hotkeyName 
                                         keyCombo:keyCombo target:self 
                                         action:@selector(hotKeyPressed:)];
    [shortcutRecorder setKeyCombo:SRMakeKeyCombo(hotKey.keyCombo.keyCode, 
                                                 [shortcutRecorder carbonToCocoaFlags:hotKey.keyCombo.modifiers])];
}

- (void)updateHotKeys {
    [self updateHotKey: leftRepeatRecorder];
    [self updateHotKey: leftHoldRecorder];
    [self updateHotKey: leftRepeatRecorder];
    [self updateHotKey: leftHoldRecorder];
}

/* Registers the hotkeys according to the SBRecorderControler identifier that we specified */
- (void)updateHotKey:(SRRecorderControl*)shortcutRecorder {
    SGHotKeyCenter *hotKeyCenter = [SGHotKeyCenter sharedCenter];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *hotkeyName = shortcutRecorder.identifier;

    id keyComboPlist = [userDefaults objectForKey:hotkeyName];
    if (keyComboPlist) {
        SGKeyCombo *keyCombo = [[SGKeyCombo alloc] initWithPlistRepresentation:keyComboPlist];

        if (![keyCombo isClearCombo]) {
            InfoLog(@"registered hotkey: %@", hotkeyName);
            SGHotKey *hotKey = [[SGHotKey alloc] initWithIdentifier:hotkeyName keyCombo:keyCombo target:self action:@selector(hotKeyPressed:)];
            [hotKeyCenter registerHotKey:hotKey];
        } else {
            InfoLog(@"unregistered hotkey: %@", hotkeyName);
            SGHotKey *hotKey = [hotKeyCenter hotKeyWithIdentifier:hotkeyName];
            [hotKeyCenter unregisterHotKey:hotKey];
        }
    }
}

- (void)iconOff {
    [view setImage:statusImage];
    [view setTitle:@""];
}

- (void)iconOn:(NSString *)text setImage:(NSImage *)image {
    [view setImage:image];
    [view setTitle:text];
}

/* Truncates the app name (so it will won't take up too much room in the menu bar) */
- (NSString *)friendlyAppName:(NSString *)text {
    int limit = 9;
    
    if ([text length] == 0) {
        return @"Unknown";
    } else if ([text length] > limit) {
        return [NSString stringWithFormat:@"%@..", [text substringToIndex:limit]];
    }
    
    return text;
}

/* Returns the pid and app name wrapped in ProcessInfo based on the app
 * underneath the mouse. Returns NULL if there is a problem.
 */
- (ProcessInfo *)processInfoUnderMouse:(NSPoint)mouse {
    NSInteger windowNumber = [NSWindow windowNumberAtPoint:mouse belowWindowWithWindowNumber:0];
    CGWindowID windowID = (CGWindowID)windowNumber;
    
    CFArrayRef array = CFArrayCreate(NULL, (const void **)&windowID, 1, NULL);
    NSArray *windowInfos = (__bridge NSArray *)CGWindowListCreateDescriptionFromArray(array);
    CFRelease(array);
    
    if (windowInfos.count > 0) {
        NSDictionary *windowInfo = [windowInfos objectAtIndex:0];
        
        /* I couldn't find any documentation on what exactly kCGWindowSharingNone prevents 
         * from being shared.  I'm keeping it in here, though, just in case.
         */
        int sharingState = [[windowInfo objectForKey:(id)kCGWindowSharingState] intValue];
        if (sharingState != kCGWindowSharingNone) {
            pid_t pid = (pid_t)[[windowInfo valueForKey:(NSString*)kCGWindowOwnerPID] longLongValue];
            NSString *appName = [windowInfo objectForKey:(NSString *)kCGWindowOwnerName];
            
            return [[ProcessInfo alloc] initWithPid:pid appName:appName];
        }
    }
    
    return NULL;
}

- (void)alertCannotRepeat:(NSString *)text {
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Failed to Repeat Click", nil)
                                     defaultButton:NSLocalizedString(@"OK", nil)
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"%@", text];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert runModal];
}

- (void)toggleRepeatClick:(RoboAction)action selector:(SEL)aSelector repeatInterval:(NSInteger)repeatInterval statusItemImage:(NSImage*)statusItemImage {
    [[self window] makeFirstResponder:nil];
    [repeatClickTimer invalidate];
    
    if (self.roboAction != action) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults boolForKey:@"bindRepeatsToPid"]) {
            NSPoint mouse = [NSEvent mouseLocation];
            ProcessInfo *processInfo = [self processInfoUnderMouse: mouse];
            
            pid_t ourPid = [[NSRunningApplication currentApplication] processIdentifier];
            
            if (processInfo == NULL) { // problem finding pid
                [self alertCannotRepeat:NSLocalizedString(@"The application you were trying to repeat click on could not be determined.\n\nIf you get this error again, try opening the RoboClick Preferences and disabling the option to keep repeat clicks to one application.", nil)];
                
                return;
            } else if ([processInfo pid] == ourPid) { // pid matches RoboClick
                NSBeep();
                InfoLog(@"RoboClick cannot repeat click on itself.");
                
                return;
            } else { // OK!
                // set the global pid
                self.repeatPid = [processInfo pid];
                
                // update the status item
                NSString *appName = [NSString stringWithFormat:@"(%@)", [self friendlyAppName:[processInfo appName]]];
                [self iconOn:appName setImage:statusItemImage];
            }
        } else {
            [self iconOn:@"" setImage:statusItemImage];
        }
        
        float timerInterval = (1.0 / repeatInterval); // make per second
        InfoLog(@"Timer interval: %f", timerInterval);
        
        repeatClickTimer = [NSTimer timerWithTimeInterval:timerInterval target:self selector:aSelector userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:repeatClickTimer forMode:NSRunLoopCommonModes];
        self.roboAction = action;
    } else {
        [self resetState];
    }
}

- (void)toggleRepeatLeftClick {
    [self toggleRepeatClick:LeftRepeat selector:@selector(repeatedLeftClick:) repeatInterval:self.leftRepeatInterval statusItemImage:statusImageRepeatLeft];
}

- (void)toggleRepeatRightClick {
    [self toggleRepeatClick:LeftRepeat selector:@selector(repeatedRightClick:) repeatInterval:self.rightRepeatInterval statusItemImage:statusImageRepeatRight];
}

- (void) drawClickIndicator:(NSPoint)mouse {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"showClickIndicator"]) {
        ringIncrementor = ((ringIncrementor + 1) % 2);

        CGFloat xPos = mouse.x - NSWidth([self.clickIndicatorWindow frame])/2;
        CGFloat yPos = mouse.y - NSHeight([self.clickIndicatorWindow frame])/2;
                
        [self.clickIndicatorWindow setFrameOrigin:NSMakePoint(xPos, yPos)];
        [self.clickIndicatorWindow makeKeyAndOrderFront:nil];
        [NSAnimationContext beginGrouping];
        
        [[NSAnimationContext currentContext] setDuration:0.2f];
        
        [self.clickIndicatorView setAlphaValue:1.0f];
        [self.clickIndicatorView setRing:3.0f];

        [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        
        // Ask the animator proxy to animatie the ring values to the new ones
        [self.clickIndicatorView.animator setAlphaValue:0.0f];
        [self.clickIndicatorView.animator setRing:((CGFloat)ringIncrementor + 6.0f)];
        [self.clickIndicatorView.animator setBallRadius:((CGFloat)ringIncrementor + 5.0f)];
        
        [NSAnimationContext endGrouping];
    }
}

/* The underlying method that the repeat click timer will call.
 * It will not click if 
 * (1) the mouse is inside RoboClick
 * (2) the pid binding option is on and the app's pid under the
 *     mouse does not match the pid we've bound to
 */
- (void)repeatedClick:(NSPoint(^)())doClickBlock {
    NSPoint mouse = [NSEvent mouseLocation];
    
    BOOL pidsMatch = true;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"bindRepeatsToPid"]) {
        // Check if pid is still alive.  If not, then stop repeating and reset state.
        NSRunningApplication *runningApp = [NSRunningApplication runningApplicationWithProcessIdentifier:self.repeatPid];
        if (runningApp == NULL) {
            [self stopRepeatClick];
            return;
        }
        
        ProcessInfo *processInfo = [self processInfoUnderMouse: mouse];
        if (processInfo == NULL) {
            pidsMatch = false;
        } else {
            InfoLog(@"appName: %@", processInfo.appName);
            pidsMatch = [processInfo pid] == self.repeatPid;
        }
    }
    
    BOOL mouseOutside = [NSWindow windowNumberAtPoint:mouse belowWindowWithWindowNumber:0] != self.window.windowNumber;
    
    if (mouseOutside && pidsMatch) {
        NSPoint clickedLocation = doClickBlock();
        
        [self drawClickIndicator:clickedLocation];
        InfoLog(@"click: done");
    } else {
        InfoLog(@"click: inside window or pids don't match");
    }
}

- (void)repeatedLeftClick:(NSTimer*)timer {
    InfoLog(@"repeatedLeftClick:");
    [self repeatedClick:^{ return [Click singleLeft]; }];
}

- (void)repeatedRightClick:(NSTimer*)timer {
    InfoLog(@"repeatedRightClick:");
    [self repeatedClick:^{ return [Click singleRight]; }];
}

/* The underlying method for toggling hold clicks. */
- (void)toggleHoldClick:(RoboAction)action statusItemImage:(NSImage*)statusItemImage clickBlock:(NSPoint(^)())doClickBlock {
    [[self window] makeFirstResponder:nil];
    [repeatClickTimer invalidate];
    
    if (self.roboAction != action) {
        NSPoint mouse = [NSEvent mouseLocation];
        BOOL mouseOutside = [NSWindow windowNumberAtPoint:mouse belowWindowWithWindowNumber:0] != self.window.windowNumber;
        
        if (mouseOutside) {
            InfoLog(@"holding in toggleHoldClick");
            self.roboAction = action;
            [self iconOn:@"" setImage:statusItemImage];
            
            NSPoint clickedLocation = doClickBlock();
            
            [self drawClickIndicator:clickedLocation];
        } else {
            NSBeep();
            InfoLog(@"failed holding in toggleHoldClick:  inside window");
        }
    } else {
        InfoLog(@"reseting state in toggleHoldClick");
        [self resetState];
    }
}

- (void)toggleHoldLeftClick {
    InfoLog(@"toggleHoldLeftClick");
    [self toggleHoldClick:LeftHold statusItemImage:statusImageHoldLeft clickBlock:^{ return [Click holdLeft]; }];
}

- (void)toggleHoldRightClick {
    InfoLog(@"toggleHoldRightClick");
    [self toggleHoldClick:RightHold statusItemImage:statusImageHoldRight clickBlock:^{ return [Click holdRight]; }];
}

/* Stop any repeat clicking timer and reset state of app. */
- (void)stopRepeatClick {
    [repeatClickTimer invalidate];
    self.roboAction = None;
    [self iconOff];
}

- (void)hotKeyPressed:(id)sender {
    InfoLog(@"hotKeyPressed.  sender: %@", sender);
    
    if ([sender isKindOfClass:[SGHotKey class]]) {
        SGHotKey *hotKey = (SGHotKey*)sender;
        
        if (hotKey.identifier == leftRepeatRecorder.identifier) {
            [self toggleRepeatLeftClick];
        } else if (hotKey.identifier == leftHoldRecorder.identifier) {
            [self toggleHoldLeftClick];
        } else if (hotKey.identifier == rightRepeatRecorder.identifier) {
            [self toggleRepeatRightClick];
        } else if (hotKey.identifier == rightHoldRecorder.identifier) {
            [self toggleHoldRightClick];
        }
    }
}

#pragma mark repeat slider Delegate

/* Save the slider value and stop auto-clicking */
- (void)leftSliderDelegate:(NSSlider*)sender {
    [self stopRepeatClick];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:self.leftRepeatInterval forKey:@"leftRepeatInterval"];
}

- (void)rightSliderDelegate:(NSSlider*)sender {
    [self stopRepeatClick];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:self.rightRepeatInterval forKey:@"rightRepeatInterval"];
}

#pragma mark shortcutRecorder Delegate

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason {
    
    /* Check if we already have this hot key registered w/in our App. */
    SGHotKeyCenter *hotKeyCenter = [SGHotKeyCenter sharedCenter];
    SGHotKey *hotKey;
    
    NSArray *allHotKeys = [hotKeyCenter allHotKeys];
    
    for (hotKey in allHotKeys) {
        if (hotKey.identifier != aRecorder.identifier) {
            if ((UInt32)hotKey.keyCombo.keyCode == keyCode && (UInt32)hotKey.keyCombo.modifierMask == flags) {
                return YES;
            }
        }
    }
    
	return NO;
}

/* If shortcutrecorder combo changes, save it to the userDefault and update the hot key center */
- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo {
    [self stopRepeatClick];
    [self resetState];
    
    SGKeyCombo *keyCombo = [SGKeyCombo keyComboWithKeyCode:[aRecorder keyCombo].code modifiers:[aRecorder cocoaToCarbonFlags:[aRecorder keyCombo].flags]];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[keyCombo plistRepresentation] forKey:aRecorder.identifier];
    [self updateHotKey: aRecorder];
    [userDefaults synchronize];
}
@end

