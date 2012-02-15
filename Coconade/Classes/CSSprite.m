/*
 * cocoshop
 *
 * Copyright (c) 2011 Andrew
 * Copyright (c) 2011-2012 Stepan Generalov
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

// TODO: Create new file to exclude Andrew's copyright & MIT License.

#import "CSSprite.h"
#import "CSObjectController.h"
#import "CSModel.h"
#import "NSString+RelativePath.h"
#import "NSObject+AMCPasteboard.h"
#import "CCNode+Helpers.h"

@interface CCNode (Internal)

-(void) _setZOrder:(int) z;

@end

@implementation CSSprite

@synthesize isSelected=isSelected_;

#pragma mark Init / DeInit

- (id)init
{
	if((self=[super init]))
	{
		[self setName:nil];
		
		fill_ = [[CCLayerColor layerWithColor:ccc4(30,144,255,25.5f)] retain];
		[self addChild:fill_];
		
		anchor_ = [[CCSprite spriteWithFile:@"anchor.png"] retain];
		[anchor_ setOpacity:200];
		[self addChild:anchor_];
		
		NSString *posText = [NSString stringWithFormat:@"%f, %f", [self position].x, [self position].y];
		positionLabel_ = [[CCLabelBMFont labelWithString:posText fntFile:@"arial.fnt"] retain];
		[anchor_ addChild:positionLabel_];
	}
	
	return self;
}

- (void)dealloc
{
	[fill_ release];
	[anchor_ release];
	[positionLabel_ release];
	[self setName:nil];
	[super dealloc];
}

#pragma mark Update 

// changes position and text of positionLabel
// must be called on Cocos2D thread
- (void)updatePositionLabel
{
	CGSize s = [anchor_ contentSize];
	NSString *posText = [NSString stringWithFormat:@"%g, %g", floorf( [self position].x ), floorf( [self position].y )];
	[positionLabel_ setString:posText];
	[positionLabel_ setPosition:ccp(s.width/2, -10)];
	
	willUpdatePositionLabel_ = NO;
}

- (void)updatePositionLabelSafely
{
	willUpdatePositionLabel_ = YES;
}

#pragma mark Properties

// TODO: move to CCNModel or CCNController
- (void)setName:(NSString *)aName
{
	if(name_ != aName)
	{
		// make the key alphanumerical + underscore
		NSCharacterSet *charactersToKeep = [NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"];
		aName = [[aName componentsSeparatedByCharactersInSet:[charactersToKeep invertedSet]] componentsJoinedByString:@"_"];		
		
		[name_ release];
		name_ = [aName copy];
	}
}

- (void)setAnchorPoint:(CGPoint)anchor
{
	
		[super setAnchorPoint:anchor];
		
		// update position of anchor point
		CGSize size = contentSize_;
		
		if( ![self isRelativeAnchorPoint] )
			[anchor_ setPosition:CGPointZero];
		else
			[anchor_ setPosition:ccp(size.width*anchorPoint_.x, size.height*anchorPoint_.y)];
	
}

- (void)setPosition:(CGPoint)pos
{
	
		[super setPosition:pos];
		[self updatePositionLabelSafely];
	
}

- (void)setRotation:(float)rot
{

		[super setRotation:rot];
		[positionLabel_ setRotation:-rot];
		//TODO: reposition somehow positionLabel_ to be always at the bottom of anchor_
		// if this is necessary 
	
}

- (void)setScaleX:(float)s
{
	
		[super setScaleX:s];
		[anchor_ setScaleX:(s != 0) ? 1.0f/s : 0];
	
}

- (void)setScaleY:(float)s
{
	
		[super setScaleY:s];
		[anchor_ setScaleY:(s != 0) ? 1.0f/s : 0];
	
}



- (void)setIsRelativeAnchorPoint:(BOOL)relative
{
	
		[super setIsRelativeAnchorPoint:relative];
		
		// update position of anchor point
		CGSize size = [self contentSize];
		if( ![self isRelativeAnchorPoint] )
			[anchor_ setPosition:CGPointZero];
		else
			[anchor_ setPosition:ccp(size.width*anchorPoint_.x, size.height*anchorPoint_.y)];
	
}

- (void)setIsSelected:(BOOL)selected
{
	if(isSelected_ != selected)
	{
		isSelected_ = selected;
		[fill_ setVisible:selected];
		[anchor_ setVisible:selected];
	}
}


#pragma mark CCNode Reimplemented Methods

- (void)onEnter
{
	[super onEnter];
	
	CGSize size = contentSize_;
	[fill_ changeWidth:size.width height:size.height];
	[anchor_ setPosition:ccp(size.width*anchorPoint_.x, size.height*anchorPoint_.y)];
	
	CGSize s = [anchor_ contentSize];
	[positionLabel_ setPosition:ccp(s.width/2, -10)];	
}

- (void)visit
{
	if(willUpdatePositionLabel_)
	{
		[self updatePositionLabel];
	}
	
	[super visit];
}

- (void)draw
{
	[super draw];
	
	// draw the outline when its selected
	if(isSelected_)
	{
		CGSize s = contentSize_;	
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		glLineWidth(1.0f);
		
		CGPoint vertices[] = {
			ccp(0, s.height),
			ccp(s.width, s.height),
			ccp(s.width, 0),
			ccp(0, 0)
		};
		
		ccDrawPoly(vertices, 4, YES);
	}
}

#pragma mark - Pasteboard support
// TODO: move these stuff to CCNode

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard 
{
    return [super writableTypesForPasteboard: pasteboard];
}

- (id)pasteboardPropertyListForType:(NSString *)type 
{
    return [super pasteboardPropertyListForType: type];
}

#pragma mark NSPasteboardReading
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard 
{    
    return [NSObject readableTypesForPasteboard: pasteboard];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard 
{
    return [NSObject readingOptionsForType:type pasteboard: pboard];
}

// Reimplement init from pasteboard method, to create new node with unique name.
- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type
{
    [self release];
    
    // Ensure name to be unique before creating instance of CCNode, cause setting
    // name property of CCNOde will instantly register it in CCNodeRegistry, overwrting
    // existing node with same name. 
    // But we want to save both nodes in CCNodeRegistry, so name must be changed in dictionary.
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: propertyList];
    NSString *name = [dict objectForKey:@"name"];
    NSString *uniqueName = [[self class] uniqueNameWithName: name];
    [dict setObject:uniqueName forKey:@"name"];    
    
    return [[NSObject objectWithDictionaryRepresentation: dict] retain];
}

@end