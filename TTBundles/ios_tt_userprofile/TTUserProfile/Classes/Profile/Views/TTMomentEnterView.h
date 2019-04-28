//
//  TTForumTableViewHeader.h
//  Article
//
//  Created by yuxin on 4/17/15.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTImageView.h"
#import "TTBadgeNumberView.h"

@interface TTMomentEnterView : SSThemedView

@property (nonatomic,weak) IBOutlet SSThemedLabel * titleLb;
@property (nonatomic,weak) IBOutlet TTImageView *  avatarImageView;
@property (nonatomic,weak) IBOutlet TTBadgeNumberView *  leftBadgeView;
@property (nonatomic,weak) IBOutlet TTBadgeNumberView *  rightBadgeView;

@property (nonatomic,weak) IBOutlet SSThemedImageView *  cellImageView;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *  titleLeftMargin;

@property (nonatomic,copy) void (^enterTouchHandler)();

- (void)setCellImageName:(NSString*)imageName;

@end
