//
//  FHUGCPostMenuView.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/17.
//

#import "FHUGCPostMenuView.h"
#import <UIColor+Theme.h>
#import <UIFont+House.h>
#import <Masonry.h>
#import "FHCommonDefines.h"

#define ANIMATION_DURATION 0.3
#define HGAP 12
#define VGAP 30

@interface FHUGCPostMenuView()
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel  *postTitleLabel;
@property (nonatomic, strong) UIButton *pubPostButton;
@property (nonatomic, strong) UILabel  *voteTitleLabel;
@property (nonatomic, strong) UIButton *pubVoteButton;
@property (nonatomic, strong) UIView *backgroupView;
@property (nonatomic, weak) UIButton *originButton;
@end

@implementation FHUGCPostMenuView

- (UIView *)backgroupView {
    if(!_backgroupView) {
        _backgroupView = [UIView new];
        _backgroupView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.56];
        UITapGestureRecognizer *tap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [_backgroupView addGestureRecognizer:tap];
    }
    return _backgroupView;
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self hide];
}

- (UIButton *)closeButton {
    if(!_closeButton) {
        _closeButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"fh_ugc_publish_menu_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (void)closeAction: (UIButton *)sender {
    [self hide];
}

- (UILabel *)postTitleLabel {
    if(!_postTitleLabel) {
        _postTitleLabel = [UILabel new];
        _postTitleLabel.text = @"发图文";
        _postTitleLabel.font = [UIFont themeFontSemibold:16];
        _postTitleLabel.textColor = [UIColor themeWhite];
        [_postTitleLabel sizeToFit];
    }
    return _postTitleLabel;
}

- (UIButton *)pubPostButton {
    if(!_pubPostButton) {
        _pubPostButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pubPostButton setImage:[UIImage imageNamed:@"fh_ugc_publish_menu_post"] forState:UIControlStateNormal];
        [_pubPostButton addTarget:self action:@selector(gotoPublishPost:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pubPostButton;
}

- (void)gotoPublishPost:(UIButton *)sender {
    [self hide];
    if([self.delegate respondsToSelector:@selector(gotoPostPublish)]) {
        [self.delegate gotoPostPublish];
    }
}

- (UILabel *)voteTitleLabel {
    if(!_voteTitleLabel) {
        _voteTitleLabel = [UILabel new];
        _voteTitleLabel.text = @"发投票";
        _voteTitleLabel.font = [UIFont themeFontSemibold:16];
        _voteTitleLabel.textColor = [UIColor themeWhite];
        [_voteTitleLabel sizeToFit];
    }
    return _voteTitleLabel;
}

- (UIButton *)pubVoteButton {
    if(!_pubVoteButton) {
        _pubVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pubVoteButton setImage:[UIImage imageNamed:@"fh_ugc_publish_menu_vote"] forState:UIControlStateNormal];
        [_pubVoteButton addTarget:self action:@selector(gotoPublishVote:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pubVoteButton;
}

- (void)gotoPublishVote:(UIButton *)sender {
    [self hide];
    if([self.delegate respondsToSelector:@selector(gotoVotePublish)]) {
        [self.delegate gotoVotePublish];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        // 添加子视图
        [self addSubview:self.backgroupView];
        [self addSubview:self.postTitleLabel];
        [self addSubview:self.pubPostButton];
        [self addSubview:self.voteTitleLabel];
        [self addSubview:self.pubVoteButton];
        [self addSubview:self.closeButton];
    }
    return self;
}

- (void)showForButton:(UIButton *)button {
    
    self.originButton = button;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    CGRect relativeRect = [self.originButton convertRect:self.originButton.bounds toView:self];
    
    self.backgroupView.frame = self.bounds;
    
    CGFloat yOffset = - relativeRect.size.height - VGAP;
    self.closeButton.frame = relativeRect;
    self.closeButton.transform = CGAffineTransformMakeRotation(-M_PI_4);

    self.pubVoteButton.frame = relativeRect;
    self.pubPostButton.frame = relativeRect;
    self.postTitleLabel.center = CGPointMake(self.pubPostButton.frame.origin.x - HGAP - self.postTitleLabel.frame.size.width / 2.0, self.pubPostButton.center.y);
    self.voteTitleLabel.center = CGPointMake(self.pubVoteButton.frame.origin.x - HGAP - self.voteTitleLabel.frame.size.width / 2.0, self.pubVoteButton.center.y);
    
    self.backgroupView.alpha = 0;
    self.pubVoteButton.alpha = 0;
    self.pubPostButton.alpha = 0;
    self.postTitleLabel.alpha = 0;
    self.voteTitleLabel.alpha = 0;
    self.originButton.hidden = YES;
    if([self.delegate respondsToSelector:@selector(postMenuViewWillShow)]) {
        [self.delegate postMenuViewWillShow];
    }
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 usingSpringWithDamping:0.45 initialSpringVelocity:4.5 options:UIViewAnimationCurveEaseOut animations:^{
        self.backgroupView.alpha = 1;
        self.closeButton.transform = CGAffineTransformIdentity;
        self.pubVoteButton.alpha = 1;
        self.pubPostButton.alpha = 1;
        self.postTitleLabel.alpha = 1;
        self.voteTitleLabel.alpha = 1;
        
        self.pubVoteButton.frame = CGRectOffset(self.closeButton.frame, 0, yOffset);
        self.pubPostButton.frame = CGRectOffset(self.pubVoteButton.frame, 0, yOffset);
        self.postTitleLabel.center = CGPointMake(self.pubPostButton.frame.origin.x - HGAP - self.postTitleLabel.frame.size.width / 2.0, self.pubPostButton.center.y);
        self.voteTitleLabel.center = CGPointMake(self.pubVoteButton.frame.origin.x - HGAP - self.voteTitleLabel.frame.size.width / 2.0, self.pubVoteButton.center.y);
    } completion:^(BOOL finished) {
        if([self.delegate respondsToSelector:@selector(postMenuViewDidShow)]) {
            [self.delegate postMenuViewDidShow];
        }
    }];
}

- (void)hide {
    
    CGRect relativeRect = [self.originButton convertRect:self.originButton.bounds toView:self];
    if([self.delegate respondsToSelector:@selector(postMenuWillHide)]) {
        [self.delegate postMenuWillHide];
    }
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.backgroupView.alpha = 0;
        self.closeButton.transform = CGAffineTransformMakeRotation(-M_PI_4);
        self.pubVoteButton.alpha = 0;
        self.pubPostButton.alpha = 0;
        self.postTitleLabel.alpha = 0;
        self.voteTitleLabel.alpha = 0;
        
        self.pubVoteButton.frame = relativeRect;
        self.pubPostButton.frame = relativeRect;
        self.postTitleLabel.center = CGPointMake(self.pubPostButton.frame.origin.x - HGAP - self.postTitleLabel.frame.size.width / 2.0, self.pubPostButton.center.y);
        self.voteTitleLabel.center = CGPointMake(self.pubVoteButton.frame.origin.x - HGAP - self.voteTitleLabel.frame.size.width / 2.0, self.pubVoteButton.center.y);
        
    } completion:^(BOOL finished) {
        self.originButton.hidden = NO;
        self.closeButton.transform = CGAffineTransformIdentity;
        [self removeFromSuperview];
        
        if([self.delegate respondsToSelector:@selector(postMenuDidHide)]) {
            [self.delegate postMenuDidHide];
        }
    }];
}
@end
