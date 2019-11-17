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

@interface FHUGCPostMenuView()
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *pubPostButton;
@property (nonatomic, strong) UIButton *pubVoteButton;
@end

@implementation FHUGCPostMenuView

- (UIButton *)closeButton {
    if(!_closeButton) {
        _closeButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"fh_ugc_publish_menu_close"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (UIButton *)pubPostButton {
    if(!_pubPostButton) {
        _pubPostButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pubPostButton setImage:[UIImage imageNamed:@"fh_ugc_publish_menu_post"] forState:UIControlStateNormal];
        [_pubPostButton setTitle:@"发贴子" forState:UIControlStateNormal];
        [_pubPostButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _pubPostButton.titleLabel.font = [UIFont themeFontRegular:18];
        _pubPostButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_pubPostButton addTarget:self action:@selector(gotoPublishPost:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pubPostButton;
}

- (void)gotoPublishPost:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(gotoPostPublish)]) {
        [self.delegate gotoPostPublish];
    }
}

- (UIButton *)pubVoteButton {
    if(!_pubVoteButton) {
        _pubVoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pubPostButton setImage:[UIImage imageNamed:@"fh_ugc_publish_menu_vote"] forState:UIControlStateNormal];
        [_pubVoteButton setTitle:@"发投票" forState:UIControlStateNormal];
        [_pubVoteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _pubVoteButton.titleLabel.font = [UIFont themeFontRegular:18];
        _pubVoteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_pubVoteButton addTarget:self action:@selector(gotoPublishVote:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pubVoteButton;
}

- (void)gotoPublishVote:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(gotoVotePublish)]) {
        [self.delegate gotoVotePublish];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.56];
        // 添加子视图
        [self addSubview:self.pubPostButton];
        [self addSubview:self.pubVoteButton];
        [self addSubview:self.closeButton];
    }
    return self;
}

- (void)show {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];

    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)hide {
    
    [UIView animateWithDuration:0.3 animations:^{
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
