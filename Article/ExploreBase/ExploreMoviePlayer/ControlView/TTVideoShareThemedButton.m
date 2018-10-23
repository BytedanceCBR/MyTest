//
//  TTVideoShareThemedButton.m
//  Article
//
//  Created by lishuangyang on 2017/7/6.
//
//

#import "TTVideoShareThemedButton.h"

@implementation TTVideoShareThemedButton

- (instancetype)initWithFrame:(CGRect)frame index:(int)index image:(UIImage *)image title:(NSString *)title needLeaveWhite:(BOOL)needLeaveWhite
{
    self.needLeaveWhite = needLeaveWhite;
    self.originFrame = frame;
    self = [super initWithFrame:frame];
    if (self) {
        SSThemedImageView *iconImage;
        if (needLeaveWhite){
            iconImage = [[SSThemedImageView alloc] initWithFrame:CGRectMake(2, 1, 40, 40)];
        }else{
            iconImage = [[SSThemedImageView alloc] initWithFrame:CGRectMake(4, 4, 28, 28)];
        }
        iconImage.image = image;
        self.iconImage = iconImage;
        
        self.backgroundColor = [UIColor clearColor];
        if (self.selectedIconImage) {
            [self addSubview:self.selectedIconImage];
        }
        if (needLeaveWhite) {
            SSThemedLabel *nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(-3, 50, 50, 15)];
            nameLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];;
            nameLabel.textColor = [UIColor tt_defaultColorForKey:kColorText9];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.text = title;
            self.nameLabel = nameLabel;
            [self addSubview:nameLabel];
        }
        self.index = index;
        [self addSubview:iconImage];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.iconImage.hidden = selected;
    self.selectedIconImage.hidden = !selected;
}

@end
