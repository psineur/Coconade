/*
 * Coconade
 *
 * Copyright (c) 2012 Alexey Lang
 *
 */

#import "CCNWindowController.h"
#import "CSMacGLView.h"

#define kCCNWindowControllerToolbarIdentifier                   @"toolbarIdentifier"

#define kCCNWindowControllerToolbarItemAddSpriteIdentifier      @"toolbarItemAddSpriteIdentifier"
#define kCCNWindowControllerToolbarItemAddSpriteName            @"Add Sprite"
#define kCCNWindowControllerToolbarItemAddSpriteImage           @"Add.tiff"

#define kCCNWindowControllerToolbarItemAddBigImageIdentifier    @"toolbarItemAddBigImageIdentifier"
#define kCCNWindowControllerToolbarItemAddBigImageName          @"Add Big Image"
#define kCCNWindowControllerToolbarItemAddBigImageImage         @"icon1.png"

#define kCCNWindowControllerToolbarItemAddLabelIdentifier       @"toolbarItemAddLabelIdentifier"
#define kCCNWindowControllerToolbarItemAddLabelName             @"Add Label"
#define kCCNWindowControllerToolbarItemAddLabelImage            @"icon3.png"

#define kCCNWindowControllerToolbarItemInfoIdentifier           @"toolbarItemInfoIdentifier"
#define kCCNWindowControllerToolbarItemInfoName                 @"Info"
#define kCCNWindowControllerToolbarItemInfoImage                @"icon4-b.png"

#define kCCNWindowControllerToolbarItemSpritesListIdentifier    @"toolbarItemSpritesListIdentifier"
#define kCCNWindowControllerToolbarItemSpritesListName          @"Sprites List"
#define kCCNWindowControllerToolbarItemSpritesListImage         @"icon7-c.png"


@implementation CCNWindowController

@synthesize glView = _glView;

#pragma mark Init/DeInit

- (void) dealloc
{
    self.glView = nil;
    
    [super dealloc];
}

#pragma mark Prapare Window

- (void) prepareWindow
{
    // setup window
    self.window.level = NSNormalWindowLevel;
    self.window.backgroundColor = [NSColor whiteColor];
    self.window.hasShadow = YES;
    self.window.acceptsMouseMovedEvents = NO;
    
    // Create and setup glView
    self.glView = [[[CSMacGLView alloc] init] autorelease];
    [self.window.contentView addSubview:self.glView];
    [self.glView awakeFromNib];
    
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:
                           kCCNWindowControllerToolbarIdentifier] autorelease];
    toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
    toolbar.delegate = self;    
    self.window.toolbar = toolbar;
}

#pragma mark Toolbar Delegate

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects: 
            kCCNWindowControllerToolbarItemAddSpriteIdentifier,
            kCCNWindowControllerToolbarItemAddBigImageIdentifier,
            kCCNWindowControllerToolbarItemAddLabelIdentifier,
            kCCNWindowControllerToolbarItemInfoIdentifier,
            kCCNWindowControllerToolbarItemSpritesListIdentifier,
            nil];
}

- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects: 
            kCCNWindowControllerToolbarItemAddSpriteIdentifier,
            kCCNWindowControllerToolbarItemAddBigImageIdentifier,
            kCCNWindowControllerToolbarItemAddLabelIdentifier,
            kCCNWindowControllerToolbarItemInfoIdentifier,
            kCCNWindowControllerToolbarItemSpritesListIdentifier,
            nil];
}

- (NSToolbarItem *)     toolbar:(NSToolbar *)toolbar
          itemForItemIdentifier:(NSString *)itemIdentifier
      willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    
    if ([itemIdentifier isEqualTo:kCCNWindowControllerToolbarItemAddSpriteIdentifier]) 
    {
        toolbarItem.label = toolbarItem.paletteLabel = toolbarItem.toolTip = kCCNWindowControllerToolbarItemAddSpriteName;
        toolbarItem.image = [NSImage imageNamed: kCCNWindowControllerToolbarItemAddSpriteImage];
    }
    else if ([itemIdentifier isEqualTo:kCCNWindowControllerToolbarItemAddBigImageIdentifier]) 
    {
        toolbarItem.label = toolbarItem.paletteLabel = toolbarItem.toolTip = kCCNWindowControllerToolbarItemAddBigImageName;
        toolbarItem.image = [NSImage imageNamed: kCCNWindowControllerToolbarItemAddBigImageImage];
    }
    else if ([itemIdentifier isEqualTo:kCCNWindowControllerToolbarItemAddLabelIdentifier]) 
    {
        toolbarItem.label = toolbarItem.paletteLabel = toolbarItem.toolTip = kCCNWindowControllerToolbarItemAddLabelName;
        toolbarItem.image = [NSImage imageNamed: kCCNWindowControllerToolbarItemAddLabelImage];
    }
    else if ([itemIdentifier isEqualTo:kCCNWindowControllerToolbarItemInfoIdentifier]) 
    {
        toolbarItem.label = toolbarItem.paletteLabel = toolbarItem.toolTip = kCCNWindowControllerToolbarItemInfoName;
        toolbarItem.image = [NSImage imageNamed: kCCNWindowControllerToolbarItemInfoImage];
    }
    else if ([itemIdentifier isEqualTo:kCCNWindowControllerToolbarItemSpritesListIdentifier]) 
    {
        toolbarItem.label = toolbarItem.paletteLabel = toolbarItem.toolTip = kCCNWindowControllerToolbarItemSpritesListName;
        toolbarItem.image = [NSImage imageNamed: kCCNWindowControllerToolbarItemSpritesListImage];
    }
    
    return toolbarItem;
}
@end
