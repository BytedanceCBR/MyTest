//
//  TTEditUserProfileItemCell.m
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import "TTEditUserProfileItemCell.h"
#import "SSAvatarView.h"
#import "TTUserProfileCheckingView.h"
#import "TTSettingConstants.h"




@implementation TTUserProfileItem
- (instancetype)init {
    if ((self = [super init])) {
        _hiddenContent = NO;
        _animating   = NO;
        _isAuditing  = NO;
        _editEnabled = YES;
        _avatarStyle = SSAvatarViewStyleRound;
        _titleThemeKey = kColorText1;
        _contentThemeKey = kColorText3;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"title = %@\ncontent = %@\nimageURLName = %@", _title, _content, _imageURLName];
}
@end


@interface TTEditUserProfileItemCell ()
@property (nonatomic, strong) SSAvatarView  *avatarView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedView  *rightView;
@property (nonatomic, strong) SSThemedLabel *contentLabel;
@property (nonatomic, strong) SSThemedImageView *arrowImageView;

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) TTUserProfileCheckingView *checkingView; //审核中

@property (nonatomic, strong) TTUserProfileItem *userItem;
@end


@implementation TTEditUserProfileItemCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.checkingView];
        [self.contentView addSubview:self.rightView];
        [self.contentView addSubview:self.loadingIndicator];
        [self.rightView addSubview:self.arrowImageView];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).with.offset([self.class spacingToMargin]);
            make.centerY.equalTo(self.contentView);
        }];
        
        CGSize size = [self.checkingView sizeForFit];
        [_checkingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right).with.offset([TTDeviceUIUtils tt_padding:kTTSettingSpacingOfTitleChecking]);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(size);
        }];
        
        [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_rightView);
            make.size.mas_equalTo(_arrowImageView.image.size);
            make.right.equalTo(_rightView.mas_right);
        }];
        
        [_loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        
        [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.greaterThanOrEqualTo(_titleLabel.mas_right).with.offset([self.class spacingOfTextArrow]);
            make.right.equalTo(self.contentView.mas_right).with.offset(-[TTDeviceUIUtils tt_padding:kTTProfileArrowInsetRight] );
            make.height.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView);
        }];

        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _userItem = nil;
    [_contentLabel removeFromSuperview];
    [_avatarView   removeFromSuperview];
}

- (void)updateConstraints {
    UIView *leftControl = !self.checkingView.hidden ? _checkingView : _titleLabel;
    [_rightView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(leftControl.mas_right).with.offset([self.class spacingOfTextArrow]);
    }];
    
    [super updateConstraints];
}

#pragma mark - reload

- (void)reloadWithProfileItem:(TTUserProfileItem *)item {
    if (!item) return;
    _userItem = item;
    
    self.titleLabel.text = item.title;
//    [self.titleLabel sizeToFit];
    if (item.titleThemeKey) {
        self.titleLabel.textColorThemeKey = item.titleThemeKey;
    }

    if (item.content) {
        _contentLabel.hidden = NO;
        _avatarView.hidden   = YES;
        
        self.contentLabel.text = item.content;
        self.contentLabel.hidden = item.hiddenContent;
//        [self.contentLabel sizeToFit];
        if (item.contentThemeKey) {
            self.contentLabel.textColorThemeKey = item.contentThemeKey;
        }
    } else {
        _contentLabel.hidden = YES;
        _avatarView.hidden   = NO;
    }
    
    if (item.image) {
        self.avatarView.avatarStyle = item.avatarStyle;
        [self.avatarView setLocalAvatarImage:item.image];
    } else if (item.imageURLName) {
        self.avatarView.avatarStyle = item.avatarStyle;
        if ([self.avatarView valueForKey:@"needDrawAvatarImage"]) {
            self.avatarView.defaultHeadImg = [self.avatarView valueForKey:@"needDrawAvatarImage"];
        }
        [self.avatarView showAvatarByURL:item.imageURLName];
    }
    if (!item.editEnabled) {
        _avatarView.alpha = 0.5;
    } else {
        _avatarView.alpha = 1.f;
    }
    
    if (item.animating) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
    self.checkingView.hidden = !item.isAuditing;
    
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (void)startAnimating {
    [self.loadingIndicator startAnimating];
}

- (void)stopAnimating {
    [self.loadingIndicator stopAnimating];
}

- (void)hiddenArrowImage{
    self.arrowImageView.hidden = YES;
    if(_contentLabel){
        [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_rightView.mas_right);
            make.centerY.equalTo(self.rightView.mas_centerY);
        }];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    
    if([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        _loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    } else {
        _loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
}

#pragma mark - lazied load

- (TTUserProfileCheckingView *)checkingView {
    if (!_checkingView) {
        _checkingView = [TTUserProfileCheckingView new];
        _checkingView.hidden = YES;
    }
    return _checkingView;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.font = [UIFont systemFontOfSize:[self.class fontSizeOfTitle]];
        _titleLabel.textColorThemeKey = kColorText1;
    }
    return _titleLabel;
}

- (SSThemedLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[SSThemedLabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentRight;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _contentLabel.textColorThemeKey = kColorText3;
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.font = [UIFont systemFontOfSize:[self.class fontSizeOfContent]];
    }
    if (!_contentLabel.superview) {
        [self.rightView addSubview:_contentLabel];
        [_contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.rightView.mas_left);
            make.right.equalTo(self.arrowImageView.mas_left).with.offset(-[self.class spacingOfTextArrow]);
            make.centerY.equalTo(self.rightView.mas_centerY);
        }];
    }
    return _contentLabel;
}

- (SSThemedView *)rightView {
    if (!_rightView) {
        _rightView = [SSThemedView new];
        _rightView.backgroundColor = [UIColor clearColor];
    }
    return _rightView;
}

- (SSThemedImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[SSThemedImageView alloc] init];
        _arrowImageView.imageName = @"setting_rightarrow";
    }
    return _arrowImageView;
}

- (SSAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[SSAvatarView alloc] initWithFrame:CGRectMake(0, 0, [self.class thumbnailHeight], [self.class thumbnailHeight])];
        _avatarView.avatarStyle = SSAvatarViewStyleRound;
        _avatarView.avatarImgPadding = [TTDeviceHelper ssOnePixel];
        _avatarView.rectangleAvatarImgRadius = 0.f;
    }
    if (!_avatarView.superview) {
        [self.rightView addSubview:_avatarView];
        [_avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([self.class thumbnailHeight]);
            make.height.mas_equalTo([self.class thumbnailHeight]);
            make.centerY.equalTo(self.rightView.mas_centerY);
            make.right.equalTo(self.arrowImageView.mas_left).with.offset(-[self.class spacingOfTextArrow]);
        }];
    }
    return _avatarView;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        UIActivityIndicatorViewStyle indicateStyle = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray;
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicateStyle];
        _loadingIndicator.center = CGPointMake([TTUIResponderHelper splitViewFrameForView:self.contentView].size.width / 2, [self.class cellHeight] / 2);
    }
    return _loadingIndicator;
}
@end
