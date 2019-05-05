//
//  TTForumTableViewHeader.h
//  Article
//
//  Created by yuxin on 4/17/15.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "SSImageView.h"
#import "TTBadgeNumberView.h"

@interface TTMomentEnterView : SSThemedView

@property (nonatomic,weak) IBOutlet SSThemedLabel * titleLb;
@property (nonatomic,weak) IBOutlet SSImageView *  avatarImageView;
@property (nonatomic,weak) IBOutlet TTBadgeNumberView *  leftBadgeView;
@property (nonatomic,weak) IBOutlet TTBadgeNumberView *  rightBadgeView;

@property (nonatomic,copy) void (^enterTouchHandler)();

@end
