//
//  AppDelegate.m
//  MovingApplication
//
//  Created by Seth Willits on 8/13/13.
//  Copyright (c) 2013 Seth Willits. All rights reserved.
//

#import "AppDelegate.h"
#import "AGApplicationMoved.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_moved = [[AGApplicationMoved watchForApplicationMoving:^{
		[NSApp terminate:nil];
	}] retain];
	
	_moved.allowRelaunch = YES;
	_moved.allowContinue = YES;
}

@end
