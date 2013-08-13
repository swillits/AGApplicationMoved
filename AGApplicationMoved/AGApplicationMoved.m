//
//  AGApplicationMoved.m
//  MovingApplication
//
//  Created by Seth Willits on 8/13/13.
//  Copyright (c) 2013 Seth Willits. All rights reserved.
//

#import "AGApplicationMoved.h"

@interface AGApplicationMoved ()
- (void)checkForApplicationBeingMoved;
- (void)relaunchAfterTermination;
@end


@implementation AGApplicationMoved

+ (AGApplicationMoved *)watchForApplicationMoving:(void (^)(void))terminationHandler;
{
	return [[[AGApplicationMoved alloc] initWithTerminationHandler:terminationHandler] autorelease];
}



- (id)initWithTerminationHandler:(void (^)(void))terminationHandler;
{
	if (!(self = [super init])) {
		return nil;
	}
	
	_mainBundleFileReferenceURL = [NSBundle.mainBundle.bundleURL.fileReferenceURL retain];
	_appRelaunchHelperURL = [[NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"AGAppRelaunch"].fileReferenceURL retain];
	_terminationHandler = [terminationHandler copy];
	
	
	FSEventStreamContext context;
	context.copyDescription = NULL;
	context.retain = NULL;
	context.release = NULL;
	context.info = self;
	context.version = 0;
	
	
	_stream = FSEventStreamCreate(NULL, MyFSEventStreamCallback, &context, (CFArrayRef)@[_mainBundleFileReferenceURL.relativePath], kFSEventStreamEventIdSinceNow, 0.0, kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagWatchRoot);
	if (_stream) {
		FSEventStreamScheduleWithRunLoop(_stream, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
		FSEventStreamStart(_stream);
	} else {
		[self release];
		return nil;
	}
	
	_allowRelaunch = NO;
	_allowContinue = YES;
	
	return self;
}



- (void)dealloc;
{
	if (_stream) {
		FSEventStreamStop(_stream);
		FSEventStreamInvalidate(_stream);
		FSEventStreamRelease(_stream);
	}
	
	[_terminationHandler release];
	[_mainBundleFileReferenceURL release];
	[_appRelaunchHelperURL release];
	[_localizedMessageText release];
	[_localizedInformativeText release];
	[super dealloc];
}



@synthesize allowRelaunch = _allowRelaunch;
@synthesize allowContinue = _allowContinue;
@synthesize localizedMessageText = _localizedMessageText;
@synthesize localizedInformativeText = _localizedInformativeText;

- (NSString *)localizedMessageText;
{
	if (_localizedMessageText) {
		return _localizedMessageText;
	}
	
	NSString * appName = NSRunningApplication.currentApplication.localizedName;
	return [NSString stringWithFormat:@"%@ was moved or renamed while running which can cause problems.", appName];
}



- (NSString *)localizedInformativeText;
{
	if (_localizedInformativeText) {
		return _localizedInformativeText;
	}
	
	NSString * appName = NSRunningApplication.currentApplication.localizedName;
	NSString * inform = nil;
	
	if (self.allowContinue) {
		inform = [NSString stringWithFormat:@"Please quit and relaunch %@, or move the application back to its original location before continuing.", appName];
	} else {
		inform = [NSString stringWithFormat:@"Please quit and relaunch %@.", appName];
	}
	
	return inform;
}



- (void)checkForApplicationBeingMoved;
{
	if (![_mainBundleFileReferenceURL.relativePath isEqual:NSBundle.mainBundle.bundlePath]) {
		NSString * defaultBtn = (self.allowRelaunch ? NSLocalizedString(@"Relaunch", nil) : NSLocalizedString(@"Quit", nil));
		NSString * continueBtn = (self.allowContinue ? NSLocalizedString(@"Continue", nil) : nil);
		
		NSAlert * alert = [NSAlert alertWithMessageText:self.localizedMessageText defaultButton:defaultBtn alternateButton:continueBtn otherButton:nil informativeTextWithFormat:@"%@", self.localizedInformativeText];
		
		alert.alertStyle = NSWarningAlertStyle;
		
		NSUInteger response = [alert runModal];
		if (response == NSAlertDefaultReturn) {
			if (self.allowRelaunch) {
				[self relaunchAfterTermination];
			}
			
			if (_terminationHandler) {
				_terminationHandler();
			} else {
				[NSApp terminate:nil];
			}
		}
	}
}



static void MyFSEventStreamCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[])
{
	for (size_t i = 0; i < numEvents; i++) {
		BOOL rootChanged = ((eventFlags[i] & kFSEventStreamEventFlagRootChanged) > 0);
		if (rootChanged) {
			[(AGApplicationMoved *)clientCallBackInfo checkForApplicationBeingMoved];
		}
	}
}



- (void)relaunchAfterTermination;
{
	[NSTask launchedTaskWithLaunchPath:_appRelaunchHelperURL.relativePath
		arguments:@[[NSString stringWithFormat:@"%d", getpid()], _mainBundleFileReferenceURL.relativePath]];
}


@end
