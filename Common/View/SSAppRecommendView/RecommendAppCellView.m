//
//  RecommendAppCellView.m
//  Essay
//
//  Created by Dianwei on 12-9-5.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RecommendAppCellView.h"
#import "SSResourceManager.h"
#import "SSLazyImageView.h"
#import "UIColorAdditions.h"

@interface RecommendAppCellView()
@property(nonatomic, retain)UIImageView *shadowImageView;
//@property(nonatomic, retain)UIImageView *nameShadowView;
@property(nonatomic, retain)SSLazyImageView *iconImageView;
@property(nonatomic, retain)UILabel *nameLabel;

@end

@implementation RecommendAppCellView

@synthesize shadowImageView/*, nameShadowView*/, iconImageView, nameLabel;

- (void)dealloc
{
    self.shadowImageView = nil;
//    self.nameShadowView = nil;
    self.nameLabel = nil;
    self.iconImageView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.shadowImageView = [[[UIImageView alloc] initWithImage:[UIImage resourceImageNamed:@"icon_shadow.png"]] autorelease];
        [shadowImageView sizeToFit];
        shadowImageView.center = CGPointMake(self.frame.size.width/2, shadowImageView.center.y);
        [self addSubview:shadowImageView];
       
        
        self.iconImageView = [[[SSLazyImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMinX(shadowImageView.frame), 65, 65)] autorelease];
        iconImageView.layer.cornerRadius = 11;
        iconImageView.clipsToBounds = YES;
        iconImageView.center = CGPointMake(shadowImageView.center.x, shadowImageView.center.y);
        iconImageView.alpha = SSUIFloat(@"uiAppIconAlpha", 1.f);
        [self addSubview:iconImageView];
        
//        self.nameShadowView = [[[UIImageView alloc] initWithImage:[UIImage resourceImageNamed:@"script_shadow.png"]] autorelease];
//        [nameShadowView sizeToFit];
//        CGRect rect = nameShadowView.frame;
//        rect.origin.y = CGRectGetMinX(shadowImageView.frame) + 66;
//        nameShadowView.frame = rect;
//        nameShadowView.center = CGPointMake(iconImageView.center.x, nameShadowView.center.y);
//        [self addSubview:nameShadowView];
        
        self.nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(iconImageView.frame) + 8, 0, 0)] autorelease];
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textColor = [UIColor colorWithHexString:SSUIString(@"uiAppCellLabelTextColor", @"ffffff")];
        nameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:nameLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeModeChanged:) name:SSResourceManagerThemeModeChangedNotification object:nil];
        [self reframeNameLabel];
    }
    
    return self;
}


- (void)themeModeChanged:(NSNotification*)notification
{
    [shadowImageView setImage:[UIImage resourceImageNamed:@"icon_shadow.png"]];
//    [nameShadowView setImage:[UIImage resourceImageNamed:@"script_shadow.png"]];
    nameLabel.textColor = [UIColor colorWithHexString:SSUIString(@"uiAppCellLabelTextColor", @"ffffff")];
    iconImageView.alpha = SSUIFloat(@"uiAppIconAlpha", 1.f);
}

- (void)reloadData:(NSDictionary*)data
{
    [iconImageView setNetImageUrl:[data objectForKey:@"icon_url"]];
    nameLabel.text = [data objectForKey:@"display_name"];
//    nameLabel.center = nameShadowView.center;
    [self reframeNameLabel];
}

- (void)reframeNameLabel
{
    [nameLabel sizeToFit];
    nameLabel.center = CGPointMake(shadowImageView.center.x, shadowImageView.center.y + 66);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
