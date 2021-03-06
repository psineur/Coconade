//
//  CCNWindow.h
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import "CCNAppDelegate.h"
#import "CCNWorkspaceController.h"
#import "DebugLog.h"
#import "CCNScene.h"
#import "NSObject+Blocks.h"
#import "CCNModel.h"
#import "CCNWindowController.h"
#import "CCNWindow.h"


@implementation CCNAppDelegate

@synthesize windowController = _windowController;
@synthesize appIsRunning = _appIsRunning; 
@synthesize filenameToOpen = _filenameToOpen;

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	if ([[filename pathExtension] isEqualToString: kCCNWindowControllerCoconadeProjectFileExtension])
	{
		DebugLog(@"Will Open File: %@", filename);
		self.filenameToOpen = filename;
		
		if (self.appIsRunning)
		{
			[self performBlockOnCocosThread:^()
             {
                 [self.windowController.workspaceController loadProject: self.filenameToOpen];             
                 self.filenameToOpen = nil;
             }];
		}
		return YES;
	}
	
	return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Prepare window & window controller.
    NSRect frame = [[NSScreen mainScreen] visibleFrame];
    NSUInteger styleMask = NSResizableWindowMask | NSClosableWindowMask | NSTitledWindowMask | NSMiniaturizableWindowMask;
    NSRect contentRect = [NSWindow contentRectForFrameRect:frame styleMask:styleMask];
    CCNWindow *window = [[[CCNWindow alloc] initWithContentRect: contentRect 
                                                      styleMask: styleMask
                                                        backing: NSBackingStoreBuffered 
                                                          defer: NO] autorelease];
    CCNMacGLView *glView = [[[CCNMacGLView alloc] init] autorelease];
    CCNWorkspaceController *workspaceController = [CCNWorkspaceController controllerWithGLView:glView];
    self.windowController = [CCNWindowController controllerWithWindow:window 
                                                  workspaceController:workspaceController];
    
    // Prepare CCDirector.
	CCDirectorMac *director = (CCDirectorMac *) [CCDirector sharedDirector];	
	[director setDisplayFPS:NO];	
	[director setOpenGLView:glView];
    glClearColor(0.91f, 0.91f, 0.91f, 1.0f);
	[director setResizeMode:kCCDirectorResize_NoScale]; //< We use NoScale with own Projection for NSScrollView
	[director setProjectionDelegate: glView];
    [director setProjection: kCCDirectorProjectionCustom]; //< Projection delegate must be set before projection itself to apply custom projection immediately.
    [glView setWorkspaceSize: workspaceController.model.currentRootNode.contentSize];
    
    // Prepare controller & run scene.
    [director runWithScene: workspaceController.scene];
	
	self.appIsRunning = YES;

    // Open file if needed ( self.filenameToOpen can be set in -application:openFile ).
	if (self.filenameToOpen)
	{
        [self performBlockOnCocosThread:^()
         {
             [workspaceController loadProject: self.filenameToOpen];             
             self.filenameToOpen = nil;
         }];       
	}
    
    [self.windowController.window makeKeyAndOrderFront: NSApp];
}

- (void)applicationWillUpdate:(NSNotification *)aNotification
{
	[[NSColorPanel sharedColorPanel] setLevel:[[[[CCDirector sharedDirector] openGLView] window] level]+1];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (void)dealloc
{
	[[CCDirector sharedDirector] release];
    self.windowController = nil;
    self.filenameToOpen = nil;
    
	[super dealloc];
}

@end
