//
//  TTNewUserContentView.m
//  Article
//
//  Created by liuzuopeng on 8/8/16.
//
//

#import "TTNewUserContentView.h"
#import "TTProfileThemeConstants.h"
#import "TTProfileHeaderVisitorView.h"
#import "TTAlphaThemedButton.h"
#import "TTImageView.h"

#import <TTAccountBusiness.h>

@interface TTTextRightArrowButton : TTAlphaThemedButton
@property (nonatomic, strong) SSThemedLabel *textLabel;
@property (nonatomic, strong) SSThemedImageView *rightArrowImageView;

@property (nonatomic, copy) NSString *text;
@end

@implementation TTTextRightArrowButton
+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    TTTextRightArrowButton *inst = [super buttonWithType:buttonType];
    if (inst) {
        inst.enableHighlightAnim = YES;
        [inst initSubviews];
    }
    return inst;
}

- (instancetype)init {
    if ((self = [super init])) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    [self addSubview:self.textLabel];
    [self addSubview:self.rightArrowImageView];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.centerY.equalTo(self);
    }];
    
    CGSize size = self.rightArrowImageView.image.size;
    [self.rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.textLabel);
        make.left.equalTo(self.textLabel.mas_right).with.offset([TTDeviceUIUtils tt_padding:12.f/2]);
        make.size.mas_equalTo(size);
        make.right.equalTo(self);
    }];
}

#pragma mark - TTTextRightArrowButton properties

- (void)setText:(NSString *)text {
    if (text != self.textLabel.text) {
        self.textLabel.text = text;
        [self.textLabel sizeToFit];
        
        CGFloat maxHeight = MAX(self.rightArrowImageView.height, self.textLabel.height);
        self.height = maxHeight;
        [self layoutIfNeeded];
    }
}

- (SSThemedLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(15, 10, 60, 60)];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kTTProfileUsernameFontSize]];
        _textLabel.textColorThemeKey = kColorText10;
    }
    return _textLabel;
}

- (SSThemedImageView *)rightArrowImageView {
    if (!_rightArrowImageView) {
        _rightArrowImageView = [SSThemedImageView new];
        _rightArrowImageView.backgroundColor = [UIColor clearColor];
        _rightArrowImageView.imageName = @"setting_rightarrow";
        _rightArrowImageView.frame = CGRectMake(0, 0, self.rightArrowImageView.image.size.width, self.rightArrowImageView.image.size.height);
    }
    return _rightArrowImageView;
}

@end


@interface TTNewUserContentView ()
@property (nonatomic, strong) SSThemedView  *avatarContainerView;
@property (nonatomic, strong) TTImageView   *avatarImageView;
@property (nonatomic, strong) TTTextRightArrowButton *usernameButton;

/**
 * 我关注的人
 * 关注我的人
 * 我的访客
 */
@property (nonatomic, strong) TTProfileHeaderVisitorView *visitorContainerView;
@end

@implementation TTNewUserContentView

#pragma mark - notifications

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    
    _avatarImageView.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground4].CGColor;
}

#pragma mark - reload

- (void)refreshUserInfo {
    //__weak typeof(self) wself = self;
    [self.avatarImageView setImageWithURLString:[TTAccountManager avatarURLString] placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
        //        [wself.baseImageView setImageName:nil];
        //        wself.baseImageView.contentMode = UIViewContentModeScaleAspectFill;
        //        [wself.baseImageView setImage:[image blurImageWithRadius:40 tintColor:[[UIColor blackColor] colorWithAlphaComponent:0.3f] saturationDeltaFactor:2.5 maskImage:nil]];
        //        wself.baseImageView.enableNightCover = YES;
        
    } failure:nil];
    self.usernameButton.text = [TTAccountManager userName];
    
    [self refreshUserVisitedHistoryInfo];
}

- (void)refreshUserVisitedHistoryInfo
{
    NSArray<TTProfileHeaderVisitorModel *> *models =
    [TTProfileHeaderVisitorModel modelsWithMoments:[TTAccountManager currentUser].momentsCount
                                        followings:[TTAccountManager currentUser].followingsCount
                                         followers:[TTAccountManager currentUser].followersCount
                                          visitors:[TTAccountManager currentUser].visitCountRecent];
    [self.visitorContainerView reloadModels:models];
}

#pragma mark - events

- (void)didTapUsernameButton:(id)sender {
    
}

#pragma mark - properties

- (TTImageView *)avatarImageView {
    if (!_avatarImageView) {
        CGFloat iconWidth = [TTDeviceUIUtils tt_padding:kTTProfileUserAvatarWidth];
        _avatarImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, iconWidth, iconWidth)];
        _avatarImageView.layer.borderWidth = 1;
        _avatarImageView.layer.cornerRadius = iconWidth / 2;
        _avatarImageView.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground4].CGColor;
        _avatarImageView.userInteractionEnabled = NO;
    }
    return _avatarImageView;
}

- (TTTextRightArrowButton *)usernameButton {
    if (!_usernameButton) {
        _usernameButton = [TTTextRightArrowButton new];
        [_usernameButton addTarget:self action:@selector(didTapUsernameButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _usernameButton;
}

- (TTProfileHeaderVisitorView *)visitorContainerView {
    if (!_visitorContainerView) {
        _visitorContainerView = [[TTProfileHeaderVisitorView alloc] initWithModels:nil];
        _visitorContainerView.backgroundColor = [UIColor clearColor];
        //        __weak typeof(self) wself = self;
        _visitorContainerView.didTapButtonCallback = ^(TTProfileHeaderVisitorView *visitorView, NSUInteger selectedIndex) {
            //            __weak typeof(wself) sself = wself;
            //            if ([sself.delegate respondsToSelector:@selector(visitorView:didSelectButtonAtIndex:)]) {
            //                [sself.delegate visitorView:visitorView didSelectButtonAtIndex:selectedIndex];
            //            }
        };
    }
    return _visitorContainerView;
}

@end
