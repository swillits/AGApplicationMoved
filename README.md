AGAppRelaunch

AGApplicationMoved
=============

AGApplicationMoved is a single class that will watching for your application being moved
while running. Finder does not prevent a user from moving your application while it's
running which can lead to crashes due to exceptions being thrown because resources
cannot be found. (NSBundle's bundleURL and bundlePath do not change to reflect the new
path the app is located at, which means nib loading during NSViewController creation
will throw an exception because the nib file can't be found.)

When the application is moved, AGApplicationMoved will display a modal dialog notifying
the user of impending doom and present them with the choice to either continue or quit
and relaunch the application.


Usage
=============

An AGApplicationMoved instance is created with a termination handler. This handler is
called when the user click on the Quit or Relaunch button in the modal dialog. In the
handler you should perform any necessary cleanup and terminate the app however you 
wish. Normally you can simply call NSApplication's -terminate: action.

	- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
	{
		_moved = [[AGApplicationMoved watchForApplicationMoving:^{
			[NSApp terminate:nil];
		}] retain];
	
		_moved.allowRelaunch = YES;
		_moved.allowContinue = YES;
	}


The AGApplicationMoved instance has two main properties which allow you to decide
whether 1) the user is allowed to continue without quitting, and 2) whether or not
the default "quit" choice in the dialog should also relaunch the application.


![Screenshot](https://github.com/swillits/AGApplicationMoved/raw/master/Screenshot.png)



Requirements
=============

There are no OS requirements for this code. It'll work in the old and new
runtimes and does not use garbage collection.



License
=============

Copyright (c) 2013, Seth Willits — Araelium Group

In plain English: do whatever you want with it, and no you do not need to give me
credit in your application/documentation. 


