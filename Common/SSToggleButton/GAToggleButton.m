//
//  GAToggleButton.m
//  MoboSquare
//
//  Created by Hu Dianwei on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GAToggleButton.h"

@interface GAToggleButton()

@end

@implementation GAToggleButton
@synthesize toggleDelegate;
@synthesize toggleOnImage, toggleOffImage, toggleOnHighlightImage, toggleOffHighlighImage;
@synthesize onTitle, offTitle;
- (void)dealloc
{
	self.toggleOnImage = nil;
	self.toggleOffImage = nil;
	self.toggleOnHighlightImage = nil;
	self.toggleOffHighlighImage = nil;
    self.onTitle = nil;
    self.offTitle = nil;
    self.imageAttributes = nil;
    self.backgroundImageAttributes = nil;
    self.textAttributes = nil;
    self.textColorAttirbutes = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) 
	{
		[self addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
        self.imageAttributes = [NSMutableDictionary dictionaryWithCapacity:2];
        self.backgroundImageAttributes = [NSMutableDictionary dictionaryWithCapacity:2];
        self.textAttributes = [NSMutableDictionary dictionaryWithCapacity:2];
        self.textColorAttirbutes = [NSMutableDictionary dictionaryWithCapacity:2];
    }
	
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL result = [super pointInside:point withEvent:event];
    return result;
}

- (void)setToggleStatus:(GAToggleButtonStatus)tStatus
{
	status = tStatus;
    [self refreshUI];
}

- (void)refreshUI
{
    UIImage *normalImage = nil, *highlightImage = nil, *normalBackgroundImage = nil, *highlightBackgroundImage = nil;
    UIColor *normalColor = nil, *highlightColor = nil;
    UIColor *normalBgColor = nil;
    NSString *title = nil;
    
    switch (status) {
		case GAToggleButtonStatusToggleOn:
		{
            normalImage = [_imageAttributes objectForKey:@(GAToggleButtonStatusToggleOn)];
            highlightImage = [_imageAttributes objectForKey:@(GAToggleButtonStatusToggleOnHighlight)];
            normalBackgroundImage = [_backgroundImageAttributes objectForKey:@(GAToggleButtonStatusToggleOn)];
            highlightBackgroundImage = [_backgroundImageAttributes objectForKey:@(GAToggleButtonStatusToggleOnHighlight)];
            normalColor = [_textColorAttirbutes objectForKey:@(GAToggleButtonStatusToggleOn)];
            highlightColor = [_textColorAttirbutes objectForKey:@(GAToggleButtonStatusToggleOnHighlight)];
            title = [_textAttributes objectForKey:@(GAToggleButtonStatusToggleOn)];
            normalBgColor = [_backgroundColorAttributes objectForKey:@(GAToggleButtonStatusToggleOn)];
		}
			break;
		case GAToggleButtonStatusToggleOff:
		{
			normalImage = [_imageAttributes objectForKey:@(GAToggleButtonStatusToggleOff)];
            highlightImage = [_imageAttributes objectForKey:@(GAToggleButtonStatusToggleOffHighlight)];
            normalBackgroundImage = [_backgroundImageAttributes objectForKey:@(GAToggleButtonStatusToggleOff)];
            highlightBackgroundImage = [_backgroundImageAttributes objectForKey:@(GAToggleButtonStatusToggleOffHighlight)];
            normalColor = [_textColorAttirbutes objectForKey:@(GAToggleButtonStatusToggleOff)];
            highlightColor = [_textColorAttirbutes objectForKey:@(GAToggleButtonStatusToggleOffHighlight)];
            title = [_textAttributes objectForKey:@(GAToggleButtonStatusToggleOff)];
            normalBgColor = [_backgroundColorAttributes objectForKey:@(GAToggleButtonStatusToggleOff)];
            
		}
			break;
		default:
			break;
	}
    
    [self setImage:normalImage forState:UIControlStateNormal];
    if(highlightImage)
    {
        [self setImage:highlightImage forState:UIControlStateHighlighted];
    }
    
    if(normalBackgroundImage)
    {
        [self setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
    }
    else
    {
        self.backgroundColor = normalBgColor;
    }
    
    if(highlightBackgroundImage)
    {
        [self setBackgroundImage:highlightBackgroundImage forState:UIControlStateHighlighted];
    }
    
    [self setTitle:title forState:UIControlStateNormal];
    
    if(normalColor)
    {
        [self setTitleColor:normalColor forState:UIControlStateNormal];
    }
    
    if(highlightColor)
    {
        [self setTitleColor:highlightColor forState:UIControlStateHighlighted];
    }
}

- (GAToggleButtonStatus)toggleStatus
{
	return status;
}


- (void)setImage:(UIImage*)image forToggleStatus:(GAToggleButtonStatus)tStatus
{
    if(image)
    {
        [_imageAttributes setObject:image forKey:@(tStatus)];
    }
    else
    {
        [_imageAttributes removeObjectForKey:@(tStatus)];
    }
}

- (void)setTitle:(NSString*)title forToggleStatus:(GAToggleButtonStatus)tStatus
{
    if(title)
    {
        [_textAttributes setObject:title forKey:@(tStatus)];
    }
    else
    {
        [_textAttributes removeObjectForKey:@(tStatus)];
    }
}

- (void)toggle
{
	if(self.toggleStatus == GAToggleButtonStatusToggleOn)
	{
		self.toggleStatus = GAToggleButtonStatusToggleOff;
	}
	else
	{
		self.toggleStatus = GAToggleButtonStatusToggleOn;
	}
	
	if(toggleDelegate)
	{
		[toggleDelegate performSelector:@selector(toggleButtonValueChanged:) withObject:self];
	}
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@_%@", [super description], [self titleForState:UIControlStateNormal]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

@end
