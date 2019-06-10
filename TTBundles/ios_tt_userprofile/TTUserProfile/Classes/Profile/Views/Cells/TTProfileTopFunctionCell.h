//
//  TTForumTopicCell.h
//  Article
//
//  Created by yuxin on 4/9/15.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTImageView.h"
#import "TTBadgeNumberView.h"
#import "TTAlphaThemedButton.h"


@interface TTProfileTopFunctionCell : SSThemedTableViewCell
@property (weak, nonatomic) IBOutlet TTAlphaThemedButton *historyBtn;
@property (weak, nonatomic) IBOutlet TTAlphaThemedButton *favBtn;
@property (weak, nonatomic) IBOutlet TTAlphaThemedButton *nightSwitchBtn;

@property (nonatomic,copy) void (^enterTouchHandler)();

@end
