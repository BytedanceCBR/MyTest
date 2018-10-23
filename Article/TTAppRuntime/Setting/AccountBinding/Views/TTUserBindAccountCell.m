//
//  TTUserBindAccountCell.m
//  Article
//
//  Created by Zuopeng Liu on 7/15/16.
//
//

#import "TTUserBindAccountCell.h"
#import "TTThirdPartyAccountInfoBase.h"
#import "TTEditAccountNameView.h"



@interface TTUserBindAccountCell ()
@property (nonatomic, strong) UISwitch *switchButton;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTEditAccountNameView *accountNameView;

@property (nonatomic, strong) TTThirdPartyAccountInfoBase *accountInfo;
@end


@implementation TTUserBindAccountCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
        self.shouldHighlight = NO;
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.switchButton];
        [self.contentView addSubview:self.accountNameView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat offsetX = [self.class spacingToMargin];
    self.titleLabel.frame = CGRectIntegral(CGRectMake(offsetX, (self.contentView.height - _titleLabel.height)/2, _titleLabel.width, _titleLabel.height));
    
    offsetX = self.contentView.width - _switchButton.width - [self.class spacingToMargin];
    _switchButton.frame = CGRectMake(offsetX, (self.contentView.height - _switchButton.height)/2, _switchButton.width, _switchButton.height);
    
    CGFloat maxWidth = SSMinX(self.switchButton) - [self.class spacingOfText] - SSMaxX(self.titleLabel);
    self.accountNameView.frame = CGRectMake(_titleLabel.right, 0, maxWidth, self.contentView.height);
}

- (void)reloadWithAccountInfo:(TTThirdPartyAccountInfoBase *)accountItem {
    if (!accountItem) return;
    _accountInfo = accountItem;
    
    self.titleLabel.text = accountItem.displayName;
    [self.titleLabel sizeToFit];
    
    [self.switchButton setOn:[accountItem logined]];
    
    NSString *accountName = (isEmptyString(accountItem.screenName) || ![accountItem logined]) ? @"" : accountItem.screenName;
    if (!isEmptyString(accountName)) {
        self.accountNameView.hidden = NO;
    
        [self.accountNameView refreshWithAccountName:accountName];
    } else {
        self.accountNameView.hidden = YES;
    }
    
    [self setNeedsLayout];
}

#pragma mark - events

- (void)accountSwitchButtonDidTap:(id)sender {
    if (_callbackDidTapBindingAccount) {
        _callbackDidTapBindingAccount(sender, _accountInfo);
    }
}


#pragma mark - lazied load

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

- (UISwitch *)switchButton {
    if (!_switchButton) {
        _switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
        [_switchButton addTarget:self action:@selector(accountSwitchButtonDidTap:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchButton;
}

- (TTEditAccountNameView *)accountNameView {
    if (!_accountNameView) {
        _accountNameView = [[TTEditAccountNameView alloc] initWithFontSize:[self.class fontSizeOfTitle]];
    }
    return _accountNameView;
}
@end
