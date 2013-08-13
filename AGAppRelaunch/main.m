//
//  main.m
//  AGAppRelaunch
//
//  Created by Seth Willits on 8/13/13.
//  Copyright (c) 2013 Araelium Group. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>


int main (int argc, const char * argv[])
{
	@autoreleasepool {
		pid_t pid = atoi(argv[1]);
		
		while (getppid() == pid) {
			sleep(1);
		}
		
		[[NSWorkspace sharedWorkspace] openFile:[NSString stringWithUTF8String:argv[2]]];	
	}
	return 0;
}

