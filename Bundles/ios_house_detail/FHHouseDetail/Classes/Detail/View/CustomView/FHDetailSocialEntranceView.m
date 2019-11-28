//
//  FHDetailSocialEntranceView.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/11/25.
//

#import "FHDetailSocialEntranceView.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "UILabel+House.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"
#import <TTSandBoxHelper.h>
#import "FHHouseNewsSocialModel.h"
#import "FHDetailNoticeAlertView.h"
#import "UIImage+FIconFont.h"

#define kFHDetailSocialAnimateDuration 0.8

@interface FHDetailSocialEntranceView()

@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UIButton *closeBtn;
@property(nonatomic , strong) UIButton *submitBtn;
@property (nonatomic, strong)   NSMutableArray       *viewsArray;
@property (nonatomic, assign)   CGRect       defaultLeftBottomFrame;
@property (nonatomic, assign)   CGRect       defaultRightBottomFrame;
@property (nonatomic, strong)   NSMutableArray       *animateArray;

@end

@implementation FHDetailSocialEntranceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    _viewsArray = [NSMutableArray new];
    _animateArray = [NSMutableArray new];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.closeBtn];
    [self addSubview:self.submitBtn];
    
    [self.closeBtn addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.submitBtn addTarget:self action:@selector(submitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(34);
        make.right.mas_equalTo(self).mas_offset(-5);
        make.top.mas_equalTo(self).mas_offset(5);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(40);
        make.left.mas_equalTo(self).mas_offset(20);
        make.right.mas_equalTo(-20);
    }];
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-20);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(-20);
    }];
}

- (void)closeButtonClick:(UIButton *)btn {
    [self stopAnimate];
    if (self.parentView) {
        [self.parentView dismiss];
    } else {
        [self removeFromSuperview];
    }
}

- (void)submitButtonClick:(UIButton *)btn {
    [self closeButtonClick:nil];
    if (self.submitBtnBlock) {
        self.submitBtnBlock();
    }
}

- (void)setSocialInfo:(FHHouseNewsSocialModel *)socialInfo {
    _socialInfo = socialInfo;
    if (socialInfo) {
        self.titleLabel.text = socialInfo.socialGroupInfo.socialGroupName;
        NSString *btnTitle = @"立即聊天";
        if (socialInfo.associateActiveInfo.associateLinkTitle.length > 0) {
            btnTitle = socialInfo.associateActiveInfo.associateLinkTitle;
        }
        [self.submitBtn setTitle:btnTitle forState:UIControlStateNormal];
        [self.submitBtn setTitle:btnTitle forState:UIControlStateHighlighted];
    }
    CGFloat messageMaxW = self.width - 112 - 20;
    CGFloat messageViewWidth = self.width - 40;
    CGFloat defaultTop = self.height - 108;
    self.defaultLeftBottomFrame = CGRectMake(20, self.height - 80, 0, 0);
    self.defaultRightBottomFrame = CGRectMake(self.width - 20, self.height - 80, 0, 0);
    [self.viewsArray enumerateObjectsUsingBlock:^(UIView*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.viewsArray removeAllObjects];
    [socialInfo.associateActiveInfo.activeInfo enumerateObjectsUsingBlock:^(FHDetailCommunityEntryActiveInfoModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHDetailSocialMessageView *mv = [[FHDetailSocialMessageView alloc] initWithFrame:CGRectMake(20, defaultTop, messageViewWidth, 28)];
        mv.messageMaxWidth = messageMaxW;
        if (idx % 2 == 0) {
            mv.direction = FHDetailSocialMessageDirectionLeft;
        } else {
            mv.direction = FHDetailSocialMessageDirectionRight;
        }
        mv.activeInfo = obj;
        mv.hidden = YES;
        [self addSubview:mv];
        [self.viewsArray addObject:mv];
    }];
}

- (void)startAnimate {
    [self.animateArray removeAllObjects];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animateRun];
    });
}

- (void)animateRun {
    if (self.viewsArray.count > 0) {
        // 取数据
        FHDetailSocialMessageView *v = [self.viewsArray lastObject];
        [self.viewsArray removeLastObject];
        v.hidden = NO;
        // 放大
        CGRect nowFrame = v.frame;
        CGRect defaultFrame = self.defaultLeftBottomFrame;
        if (v.direction == FHDetailSocialMessageDirectionLeft) {
            defaultFrame = self.defaultLeftBottomFrame;
        } else if (v.direction == FHDetailSocialMessageDirectionRight) {
            defaultFrame = self.defaultRightBottomFrame;
        }
        v.frame = defaultFrame;
        [self.animateArray addObject:v];
        __weak typeof(self) weakSelf = self;
        [v startAnimation];
        [UIView animateWithDuration:kFHDetailSocialAnimateDuration animations:^{
            v.frame = nowFrame;
            [v runAnimation];
        } completion:^(BOOL finished) {
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kFHDetailSocialAnimateDuration + 0.2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 整体上移
            if (weakSelf.viewsArray.count > 0) {
                [weakSelf animateUp];
            }
        });
    }
}

- (void)animateUp {
    if (self.animateArray.count > 0) {
        __weak typeof(self) weakSelf = self;
        NSInteger count = self.animateArray.count;
        [UIView animateWithDuration:kFHDetailSocialAnimateDuration animations:^{
            [weakSelf.animateArray enumerateObjectsUsingBlock:^(UIView*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (count - idx > 2) {
                    obj.alpha = 0;
                    obj.top -= 20;
                } else {
                    obj.top -= 33;
                }
            }];
        } completion:^(BOOL finished) {
            
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kFHDetailSocialAnimateDuration + 0.2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 继续动画
            [weakSelf animateRun];
        });
    }
}

- (void)stopAnimate {
    [self.animateArray removeAllObjects];
    [self.viewsArray removeAllObjects];
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontMedium:24];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _titleLabel;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc]init];
        UIImage *img = ICON_FONT_IMG(13, @"\U0000e673", nil);
        [_closeBtn setImage:img forState:UIControlStateNormal];
        [_closeBtn setImage:img forState:UIControlStateHighlighted];
    }
    return _closeBtn;
}

- (UIButton *)submitBtn
{
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc]init];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _submitBtn.titleLabel.font = [UIFont themeFontRegular:16];
        [_submitBtn setTitle:@"立即加入" forState:UIControlStateNormal];
        [_submitBtn setTitle:@"立即加入" forState:UIControlStateHighlighted];
        _submitBtn.layer.cornerRadius = 4;
        _submitBtn.backgroundColor = [UIColor themeRed1];
    }
    return _submitBtn;
}

@end

// FHDetailSocialMessageView
@interface FHDetailSocialMessageView()

@property (nonatomic, strong)   UIImageView       *iconImageView;
@property (nonatomic, strong)   UIView       *rightBgView;
@property (nonatomic, strong)   UILabel       *messageLabel;

@property (nonatomic, assign)   CGRect       originIconFrame;
@property (nonatomic, assign)   CGRect       originBgFrame;
@property (nonatomic, assign)   CGRect       originMessageFrame;

@end

@implementation FHDetailSocialMessageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.clipsToBounds = YES;
    _direction = FHDetailSocialMessageDirectionNone;
    // 28 * 28
    _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    _iconImageView.layer.cornerRadius = 14;
    _iconImageView.clipsToBounds = YES;
    [self addSubview:_iconImageView];
    _rightBgView = [[UIView alloc] initWithFrame:CGRectZero];
    _rightBgView.layer.cornerRadius = 4;
    _rightBgView.clipsToBounds = YES;
    _rightBgView.backgroundColor = [UIColor themeRed1];
    [self addSubview:_rightBgView];
    
    _messageLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _messageLabel.textColor = [UIColor themeWhite];
    [self addSubview:_messageLabel];
}

- (void)setActiveInfo:(FHDetailCommunityEntryActiveInfoModel *)activeInfo {
    _activeInfo = activeInfo;
    if (activeInfo) {
        [self.iconImageView bd_setImageWithURL:[NSURL URLWithString:activeInfo.activeUserAvatar] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
        self.messageLabel.text = activeInfo.suggestInfo;
        CGSize size = [self.messageLabel sizeThatFits:CGSizeMake(2000, 18)];
        CGFloat messageW = size.width > self.messageMaxWidth ? self.messageMaxWidth : size.width + 1;
        
        // 方向
        if (self.direction == FHDetailSocialMessageDirectionLeft) {
            self.iconImageView.frame = CGRectMake(0, 0, 28, 28);
            self.rightBgView.frame = CGRectMake(36, 2, messageW + 20, 24);
            self.messageLabel.frame = CGRectMake(46, 2, messageW, 24);
        } else if (self.direction == FHDetailSocialMessageDirectionRight) {
            self.iconImageView.frame = CGRectMake(self.width - 28, 0, 28, 28);
            self.rightBgView.frame = CGRectMake(self.iconImageView.left - 8 - (messageW + 20), 2, messageW + 20, 24);
            self.messageLabel.frame = CGRectMake(self.rightBgView.left + 10, 2, messageW, 24);
        }
        
        [self layoutIfNeeded];
    }
}

- (void)setDirection:(FHDetailSocialMessageDirection)direction {
    _direction = direction;
}

- (void)startAnimation {
    self.originIconFrame = self.iconImageView.frame;
    self.originBgFrame = self.rightBgView.frame;
    self.originMessageFrame = self.messageLabel.frame;
    
    self.iconImageView.layer.cornerRadius = 0;

    if (self.direction == FHDetailSocialMessageDirectionLeft) {
        self.iconImageView.frame = CGRectMake(0, 0, 0, 0);
        self.rightBgView.frame = CGRectMake(0, 0, 0, 0);
        self.messageLabel.frame = CGRectMake(0, 0, 0, 0);
    } else if (self.direction == FHDetailSocialMessageDirectionRight) {
        self.iconImageView.frame = CGRectMake(self.width, 0, 0, 0);
        self.rightBgView.frame = CGRectMake(self.width, 0, 0, 0);
        self.messageLabel.frame = CGRectMake(self.width, 0, 0, 0);
    }
}

- (void)runAnimation {
    self.iconImageView.frame = self.originIconFrame;
    self.rightBgView.frame = self.originBgFrame;
    self.messageLabel.frame = self.originMessageFrame;
    self.iconImageView.layer.cornerRadius = 14;
}

@end
