//
//  TTVReplyTopBar.h
//  Article
//
//  Created by lijun.thinker on 2017/6/2.
//
//

#import "SSViewBase.h"
#import "TTAlphaThemedButton.h"

@class TTVReplyViewController;
@interface TTVReplyTopBar : SSViewBase

@property (nonatomic, strong) TTAlphaThemedButton *closeBtn;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedView *lineView;
@property (nonatomic, strong) UIImageView *shadowView;

@end
