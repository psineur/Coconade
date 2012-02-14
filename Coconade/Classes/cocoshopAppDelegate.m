/*
 * cocoshop
 *
 * Copyright (c) 2011 Andrew
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "cocoshopAppDelegate.h"
#import "CSObjectController.h"
#import "DebugLog.h"
#import "CCNScene.h"
#import "CSModel.h"

@implementation cocoshopAppDelegate
@synthesize window=window_, glView=glView_, controller=controller_;
@synthesize appIsRunning = appIsRunning_, filenameToOpen = filenameToOpen_;

// Can be called before -applicationDidFinishLaunching: if app is open by double-clicking csd file.
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	if ([[filename pathExtension] isEqualToString: @"csd"])
	{
		DebugLog(@"Will Open File: %@", filename);
		self.filenameToOpen = filename;
		
		if (self.appIsRunning)
		{
			NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: filename];
			[controller_ loadProjectFromDictionarySafely: dict];
			controller_.projectFilename = self.filenameToOpen;
			self.filenameToOpen = nil;
		}
		return YES;
	}
	
	return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[director setDisplayFPS:NO];
    
    // Enable notifications from glView for updateForScreenReshape.
    [glView_ setPostsFrameChangedNotifications: YES];    
	
	// register for receiving filenames
	[glView_ registerForDraggedTypes:[NSArray arrayWithObjects:  NSFilenamesPboardType, nil]];
	[director setOpenGLView:glView_];
	
	// We use NoScale with own Projection for NSScrollView
	[director setResizeMode:kCCDirectorResize_NoScale];
	[director setProjection: kCCDirectorProjectionCustom];
	[director setProjectionDelegate: glView_];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
    // Prepare scene.
	CCNScene *scene = [CCNScene node];
    
    // Show Borders if needed (On first run)
    NSNumber *showBordersState = [[NSUserDefaults standardUserDefaults] valueForKey:@"CSMainLayerShowBorders"];
    if (!showBordersState)
        scene.showBorders = YES;
    else 
        scene.showBorders = [showBordersState intValue];
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    [glView_ setWorkspaceSize: s];
    [glView_ updateWindow ];
    glView_.gestureEventsDelegate = controller_;
    
	CCLayer *defaultRootNode = [CCLayer node];
    CCLayerColor *bgLayer = [[controller_ modelObject] backgroundLayer];
    if (bgLayer)
        [defaultRootNode addChild:bgLayer z:NSIntegerMin];
    
	scene.targetNode = defaultRootNode;
	[director runWithScene:scene];
	
	self.appIsRunning = YES;

    // Open file if needed ( self.filenameToOpen can be set in -application:openFile ).
	if (self.filenameToOpen)
	{
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: self.filenameToOpen];
        controller_.projectFilename = self.filenameToOpen;
        [controller_ loadProjectFromDictionarySafely: dict];			
        self.filenameToOpen = nil;
	}
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
	[window_ release];
	[super dealloc];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
	
	[(CSMacGLView *)[director openGLView] updateWindow];
}

@end
