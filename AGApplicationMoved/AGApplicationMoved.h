//
//  AGApplicationMoved.h
//  MovingApplication
//
//  Created by Seth Willits on 8/13/13.
//  Copyright (c) 2013 Seth Willits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGApplicationMoved : NSObject
{
	NSURL * _mainBundleFileReferenceURL;
	NSURL * _appRelaunchHelperURL;
	void (^_terminationHandler)(void);
	FSEventStreamRef _stream;
	
	BOOL _allowRelaunch;
	BOOL _allowContinue;
	NSString * _localizedMessageText;
	NSString * _localizedInformativeText;
}


+ (AGApplicationMoved *)watchForApplicationMoving:(void (^)(void))terminationHandler;

@property (nonatomic, readwrite) BOOL allowRelaunch;
@property (nonatomic, readwrite) BOOL allowContinue;

@property (nonatomic, readwrite, copy) NSString * localizedMessageText;
@property (nonatomic, readwrite, copy) NSString * localizedInformativeText;

@end
