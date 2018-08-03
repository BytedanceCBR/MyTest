//
//  VideoTitleBarSegment.m
//  Video
//
//  Created by 于 天航 on 12-7-30.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SSTitleBarSegment.h"
#import "UIColorAdditions.h"

@interface SSTitleBarSegment ()
@property (nonatomic) SSTitleBarSegmentType type;
@property (nonatomic, retain, readwrite) UILabel *subTitleLabel;
@end


@implementation SSTitleBarSegment

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.subTitleLabel = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame type:SSTitleBarSegmentTypeLeft];
}

- (id)initWithFrame:(CGRect)frame type:(SSTitleBarSegmentType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        
        self.titleLabel.font = [UIFont systemFontOfSize:14.f];
        
        self.subTitleLabel = [[[UILabel alloc] init] autorelease];
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.font = [UIFont systemFontOfSize:14.f];
        [self addSubview:_subTitleLabel];
        
        [self refreshUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:SSResourceManagerThemeModeChangedNotification object:nil];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notifcation
{
    [self refreshUI];
    self.checked = _checked;
}

- (void)setSubtitle:(NSString *)subTitle
{
    _subTitleLabel.text = subTitle;
    [self refreshUI];
}

- (void)setType:(SSTitleBarSegmentType)type
{
    _type = type;
    [self refreshUI];
}

- (void)setChecked:(BOOL)checked
{
    [super setChecked:checked];
    [self refreshUI];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        _subTitleLabel.textColor = [self titleColorForState:UIControlStateHighlighted];
    }
    else{
        _subTitleLabel.textColor = [self titleColorForState:UIControlStateNormal];
    }
}

- (void)refreshUI
{
    // images
    switch (_type) {
        case SSTitleBarSegmentTypeSubtitleLeft:
        {
            [self setBackgroundImage:[[UIImage resourceImageNamed:@"followbtn_friend.png"]
                                      stretchableImageWithLeftCapWidth:53 topCapHeight:22]
                            forState:UIControlStateNormal];
            [self setBackgroundImage:[[UIImage resourceImageNamed:@"followbtn_friend_press.png"]
                                      stretchableImageWithLeftCapWidth:53 topCapHeight:22]
                            forState:UIControlStateHighlighted];
        }
            break;
        case SSTitleBarSegmentTypeSubtitleMiddle:
        {
            [self setBackgroundImage:[UIImage resourceImageNamed:@"fanbtn_friend.png"] forState:UIControlStateNormal];
            [self setBackgroundImage:[UIImage resourceImageNamed:@"fanbtn_friend_press.png"] forState:UIControlStateHighlighted];
        }
            break;
        case SSTitleBarSegmentTypeSubtitleRight:
        {
            [self setBackgroundImage:[[UIImage resourceImageNamed:@"addbtn_friend.png"]
                                      stretchableImageWithLeftCapWidth:53 topCapHeight:22]
                            forState:UIControlStateNormal];
            [self setBackgroundImage:[[UIImage resourceImageNamed:@"addbtn_friend_press.png"]
                                      stretchableImageWithLeftCapWidth:53 topCapHeight:22]
                            forState:UIControlStateHighlighted];
        }
            break;
        case SSTitleBarSegmentTypeLeft:
        {
            [self setBackgroundImage:[UIImage resourceImageNamed:@"updatebtn_profile.png"] forState:UIControlStateNormal];
            [self setBackgroundImage:[UIImage resourceImageNamed:@"updatebtn_profile_press.png"] forState:UIControlStateHighlighted];
        }
            break;
        case SSTitleBarSegmentTypeMiddle:
        {
            [self setBackgroundImage:[UIImage resourceImageNamed:@"commentbtn_profile.png"] forState:UIControlStateNormal];
            [self setBackgroundImage:[UIImage resourceImageNamed:@"commentbtn_profile_press.png"] forState:UIControlStateHighlighted];
        }
            break;
        case SSTitleBarSegmentTypeRight:
        {
            [self setBackgroundImage:[UIImage resourceImageNamed:@"favoritebtn_profile.png"] forState:UIControlStateNormal];
            [self setBackgroundImage:[UIImage resourceImageNamed:@"favoritebtn_profile_press.png"] forState:UIControlStateHighlighted];
        }
            break;
        default:
            break;
    }
    
    // colors
    if (self.checked) {
        switch (_type) {
            case SSTitleBarSegmentTypeSubtitleLeft:
            case SSTitleBarSegmentTypeSubtitleMiddle:
            case SSTitleBarSegmentTypeSubtitleRight:
            case SSTitleBarSegmentTypeLeft:
            case SSTitleBarSegmentTypeMiddle:
            case SSTitleBarSegmentTypeRight:
            {
                [self setTitleColor:[UIColor colorWithHexString:SSUIStringNoDefault(@"SSTitleBarSegmentTypeNormalCheckedColor")]
                           forState:UIControlStateNormal];
                [self setTitleColor:[UIColor colorWithHexString:SSUIStringNoDefault(@"SSTitleBarSegmentTypeNormalCheckedColor")]
                           forState:UIControlStateHighlighted];
            }
                break;
            default:
                break;
        }
        
    }
    else {
        switch (_type) {
            case SSTitleBarSegmentTypeSubtitleLeft:
            case SSTitleBarSegmentTypeSubtitleMiddle:
            case SSTitleBarSegmentTypeSubtitleRight:
            case SSTitleBarSegmentTypeLeft:
            case SSTitleBarSegmentTypeMiddle:
            case SSTitleBarSegmentTypeRight:
            {
                [self setTitleColor:[UIColor colorWithHexString:SSUIStringNoDefault(@"SSTitleBarSegmentTypeNormalTitleColor")]
                           forState:UIControlStateNormal];
                [self setTitleColor:[UIColor colorWithHexString:SSUIStringNoDefault(@"SSTitleBarSegmentTypeNormalTitleColor")]
                           forState:UIControlStateHighlighted];
            }
                break;
            default:
                break;
        }
    }

    _subTitleLabel.hidden = [_subTitleLabel.text length] == 0;
    if (!_subTitleLabel.hidden) {
        CGRect vFrame = self.frame;
        vFrame.origin.x = 0;
        vFrame.origin.y = 0;
        
        [_subTitleLabel sizeToFit];
        _subTitleLabel.center = CGPointMake(vFrame.size.width/2, vFrame.size.height/2 - 9.f);
        [self setTitleEdgeInsets:UIEdgeInsetsMake(18.f, 0, 0, 0)];
        [self bringSubviewToFront:_subTitleLabel];
    }
    else {
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}
@end
