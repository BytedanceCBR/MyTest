//
//  FHHomeEntranceItemView.m
//  FHHouseBase
//
//  Created by 张静 on 2019/12/12.
//

#import "FHHomeEntranceItemView.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import <TTBaseLib/UIViewAdditions.h>

@implementation FHHomeEntranceItemView

-(instancetype)initWithFrame:(CGRect)frame iconSize:(CGSize)iconSize
{
    self = [super initWithFrame:frame];
    if (self) {
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - iconSize.width)/2, 0, iconSize.width, iconSize.height)];
        [self addSubview:_iconView];
        [self.iconView setBackgroundColor:[UIColor clearColor]];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 20, frame.size.width, 20)];
        _nameLabel.textColor = [UIColor themeGray2];
        _nameLabel.font = [TTDeviceHelper isScreenWidthLarge320] ? [UIFont themeFontRegular:12] : [UIFont themeFontRegular:12];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:_nameLabel];
        self.clipsToBounds = NO;
    }
    return self;
}

-(void)updateWithIconUrl:(NSString *)iconUrl name:(NSString *)name placeHolder:(UIImage *)placeHolder
{
    [self.iconView bd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholder:placeHolder];
    _nameLabel.text = name;
    [_nameLabel sizeToFit];
    _nameLabel.centerX = self.width/2;
}

@end
