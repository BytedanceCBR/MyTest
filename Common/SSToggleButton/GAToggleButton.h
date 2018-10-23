//
//  GAToggleButton.h
//  MoboSquare
//
//  Created by Hu Dianwei on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum GAToggleButtonStatus
{
	GAToggleButtonStatusToggleOn,
	GAToggleButtonStatusToggleOff,
	GAToggleButtonStatusToggleOnHighlight,
	GAToggleButtonStatusToggleOffHighlight
}GAToggleButtonStatus;

@class GAToggleButton;
@protocol GAToggleButtonDelegate
- (void)toggleButtonValueChanged:(GAToggleButton*)button;

@end


@interface GAToggleButton : UIButton {
	UIImage *toggleOnImage, *toggleOffImage;
	UIImage *toggleOnHighlightImage, *toggleOffHighlighImage;
	GAToggleButtonStatus status;
	NSObject<GAToggleButtonDelegate> *toggleDelegate;
    NSString *onTitle, *offTitle;
}

- (void)setImage:(UIImage*)image forToggleStatus:(GAToggleButtonStatus)tStatus;
- (void)setTitle:(NSString*)title forToggleStatus:(GAToggleButtonStatus)tStatus;
- (void)toggle;
- (void)refreshUI;

@property(nonatomic, assign)GAToggleButtonStatus toggleStatus;
@property(nonatomic, assign)NSObject<GAToggleButtonDelegate> *toggleDelegate;
@property(nonatomic, retain)UIImage *toggleOnImage;
@property(nonatomic, retain)UIImage *toggleOffImage;
@property(nonatomic, retain)UIImage *toggleOnHighlightImage;
@property(nonatomic, retain)UIImage *toggleOffHighlighImage;
@property(nonatomic, copy)NSString *onTitle;
@property(nonatomic, copy)NSString *offTitle;

@property(nonatomic, retain)NSMutableDictionary *imageAttributes;
@property(nonatomic, retain)NSMutableDictionary *backgroundImageAttributes;
@property(nonatomic, retain)NSMutableDictionary *textAttributes;
@property(nonatomic, retain)NSMutableDictionary *textColorAttirbutes;
@property(nonatomic, retain)NSDictionary *backgroundColorAttributes;
@end
