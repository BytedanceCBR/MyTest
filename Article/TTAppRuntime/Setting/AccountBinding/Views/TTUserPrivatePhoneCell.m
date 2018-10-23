//
//  TTUserPrivatePhoneCell.m
//  Article
//
//  Created by tyh on 2017/6/29.
//
//

#import "TTUserPrivatePhoneCell.h"
#import "TTAccountManager.h"

@interface TTUserPrivatePhoneCell()

@property (nonatomic, strong) UISwitch *switchButton;
@property (nonatomic, strong) SSThemedLabel *titleLabel;


@end

@implementation TTUserPrivatePhoneCell



- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
        self.shouldHighlight = NO;
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.switchButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
        
    CGFloat offsetX = [self.class spacingToMargin];
    
    self.titleLabel.frame = CGRectIntegral(CGRectMake(offsetX, (self.contentView.height - _titleLabel.height)/2, _titleLabel.width, _titleLabel.height));
    
    offsetX = self.contentView.width - _switchButton.width - [self.class spacingToMargin];
    _switchButton.frame = CGRectMake(offsetX, (self.contentView.height - _switchButton.height)/2, _switchButton.width, _switchButton.height);
    
}


#pragma mark - lazied load

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.text = @"通过手机号可以找到我";

        _titleLabel.font = [UIFont systemFontOfSize:[self.class fontSizeOfTitle]];
        [_titleLabel sizeToFit];

        _titleLabel.textColorThemeKey = kColorText1;
    }
    return _titleLabel;
}

- (UISwitch *)switchButton {
    if (!_switchButton) {
        _switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
        [_switchButton addTarget:self action:@selector(accountSwitchButtonDidTap:) forControlEvents:UIControlEventValueChanged];
        _switchButton.on = [TTAccountManager currentUser].canBeFoundByPhone;
 
    }
    return _switchButton;
}

- (void)accountSwitchButtonDidTap:(UISwitch *)sender {
    [TTAccountManager currentUser].canBeFoundByPhone = sender.isOn;
}


@end
