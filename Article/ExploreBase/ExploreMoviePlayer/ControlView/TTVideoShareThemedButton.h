//
//  TTVideoShareThemedButton.h
//  Article
//
//  Created by lishuangyang on 2017/7/6.
//
//

#import "SSThemed.h"

@interface TTVideoShareThemedButton : SSThemedButton

@property (nonatomic, assign) int index;
@property (nonatomic, strong) SSThemedImageView *iconImage;
@property (nonatomic, strong) SSThemedImageView *selectedIconImage;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, assign) CGRect originFrame;// 未留白时原始frame
@property (nonatomic, assign) BOOL needLeaveWhite;//ipad 需要留白
@property (nonatomic, copy) NSString *activityType;

- (instancetype)initWithFrame:(CGRect)frame index:(int)index image:(UIImage *)image title:(NSString *)title needLeaveWhite:(BOOL)needLeaveWhite;
- (void)setSelected:(BOOL)selected;

@end
