//
//  SSSocialActionButton.m
//  Gallery
//
//  Created by Zhang Leonardo on 12-10-29.
//
//

#import "SSSocialActionButton.h"

@interface SSSocialActionButton()
@property(nonatomic, assign, readwrite)SSSocialActionButtonActionType actionType;
@end

@implementation SSSocialActionButton

@synthesize actionType = _actionType;

@synthesize normalBGImg = _normalBGImg;
@synthesize normalImg = _normalImg;
@synthesize normalTitleColor = _normalTitleColor;

@synthesize selectedImg = _selectedImg;
@synthesize selectedBGImg = _selectedBGImg;
@synthesize selectedTitleColor = _selectedTitleColor;


@synthesize normalHighlightImg = _normalHighlightImg;
@synthesize normalHighlightBGImg = _normalHighlightBGImg;
@synthesize normalHighlightTitleColor = _normalHighlightTitleColor;

@synthesize selectedHighlightImg = _selectedHighlightImg;
@synthesize selectedHighlightBGImg = _selectedHighlightBGImg;
@synthesize selectedHighlightTitleColor = _selectedHighlightTitleColor;

@synthesize normalDisableBGImg = _normalDisableBGImg;
@synthesize normalDisableImg = _normalDisableImg;
@synthesize normalDisableTitleColor = _normalDisableTitleColor;

@synthesize selectedDisableImg = _selectedDisableImg;
@synthesize selectedDisableBGImg = _selectedDisableBGImg;
@synthesize selectedDisableTitleColor = _selectedDisableTitleColor;

- (void)dealloc
{
    self.normalBGImg = nil;
    self.normalTitleColor = nil;
    self.normalImg = nil;
    
    self.normalHighlightImg = nil;
    self.normalHighlightTitleColor = nil;
    self.normalHighlightBGImg = nil;

    self.selectedImg = nil;
    self.selectedBGImg = nil;
    self.selectedTitleColor = nil;
    
    self.selectedHighlightImg = nil;
    self.selectedHighlightBGImg = nil;
    self.selectedHighlightTitleColor = nil;
    
    self.normalDisableBGImg = nil;
    self.normalDisableImg = nil;
    self.normalDisableTitleColor = nil;
    
    self.selectedDisableImg = nil;
    self.selectedHighlightBGImg = nil;
    self.selectedDisableTitleColor = nil;
    
    [super dealloc];
}

#pragma mark -- public

- (void)changeStatus:(SSSocialActionButtonActionType)type
{
    switch (type) {
        case SSSocialActionButtonActionTypeNormal:
        {
            self.enabled = YES;
            
            [self setBackgroundImage:_normalBGImg forState:UIControlStateNormal];
            [self setBackgroundImage:_selectedBGImg forState:UIControlStateSelected];
            [self setBackgroundImage:_normalHighlightBGImg forState:UIControlStateHighlighted];
            
            [self setImage:_normalImg forState:UIControlStateNormal];
            [self setImage:_selectedImg forState:UIControlStateSelected];
            [self setImage:_normalHighlightImg forState:UIControlStateHighlighted];
            
            [self setTitleColor:_normalTitleColor forState:UIControlStateNormal];
            [self setTitleColor:_normalHighlightTitleColor forState:UIControlStateHighlighted];
            [self setTitleColor:_selectedHighlightTitleColor forState:UIControlStateSelected];
        }
            break;
        case SSSocialActionButtonActionTypeSelected:
        {
            self.enabled = YES;
            
            [self setBackgroundImage:_selectedBGImg forState:UIControlStateNormal];
            [self setBackgroundImage:_selectedBGImg forState:UIControlStateSelected];
            [self setBackgroundImage:_selectedHighlightBGImg forState:UIControlStateHighlighted];
            
            [self setImage:_selectedImg forState:UIControlStateNormal];
            [self setImage:_selectedImg forState:UIControlStateSelected];
            [self setImage:_selectedHighlightImg forState:UIControlStateHighlighted];
            
            [self setTitleColor:_selectedTitleColor forState:UIControlStateNormal];
            [self setTitleColor:_selectedTitleColor forState:UIControlStateSelected];
            [self setTitleColor:_selectedHighlightTitleColor forState:UIControlStateHighlighted];
        }
            break;
        case SSSocialActionButtonActionTypeNormalWithDisable:
        {
            
            [self setBackgroundImage:_normalDisableBGImg forState:UIControlStateNormal];
            [self setBackgroundImage:_normalDisableBGImg forState:UIControlStateSelected];
            [self setBackgroundImage:_normalDisableBGImg forState:UIControlStateHighlighted];
            [self setBackgroundImage:_normalDisableBGImg forState:UIControlStateDisabled];
            
            [self setImage:_normalDisableImg forState:UIControlStateNormal];
            [self setImage:_normalDisableImg forState:UIControlStateSelected];
            [self setImage:_normalDisableImg forState:UIControlStateHighlighted];
            [self setImage:_normalDisableImg forState:UIControlStateDisabled];
            
            [self setTitleColor:_normalDisableTitleColor forState:UIControlStateNormal];
            [self setTitleColor:_normalDisableTitleColor forState:UIControlStateSelected];
            [self setTitleColor:_normalDisableTitleColor forState:UIControlStateHighlighted];
            
            self.enabled = NO;
        }
            break;
        case SSSocialActionButtonActionTypeSelectedWithDisable:
        {
            [self setBackgroundImage:_selectedDisableBGImg forState:UIControlStateNormal];
            [self setBackgroundImage:_selectedDisableBGImg forState:UIControlStateSelected];
            [self setBackgroundImage:_selectedDisableBGImg forState:UIControlStateHighlighted];
            [self setBackgroundImage:_selectedDisableBGImg forState:UIControlStateDisabled];
            
            [self setImage:_selectedDisableImg forState:UIControlStateNormal];
            [self setImage:_selectedDisableImg forState:UIControlStateSelected];
            [self setImage:_selectedDisableImg forState:UIControlStateHighlighted];
            [self setImage:_selectedDisableImg forState:UIControlStateDisabled];
            
            [self setTitleColor:_selectedDisableTitleColor forState:UIControlStateNormal];
            [self setTitleColor:_selectedDisableTitleColor forState:UIControlStateSelected];
            [self setTitleColor:_selectedDisableTitleColor forState:UIControlStateHighlighted];
            
            self.enabled = NO;
        }
            
            break;
        default:
            break;
    }
    self.actionType = type;    
}


@end
