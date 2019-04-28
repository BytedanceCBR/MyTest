//
//  TTUserShareToRepostCell.m
//  Article
//
//  Created by 王霖 on 2017/8/8.
//
//

#import "TTUserShareToRepostCell.h"
#import <TTAccountManager.h>
#import <TTNetworkManager.h>
//#import "TTShareToRepostManager.h"

@interface TTUserShareToRepostCell ()

@property (nonatomic, strong) SSThemedLabel * shareToRepostTitleLabel;
@property (nonatomic, strong) UISwitch * shareToRepostSwitch;

@end

@implementation TTUserShareToRepostCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.shouldHighlight = NO;
        [self createComponent];
    }
    return self;
}

- (void)createComponent {
    CGFloat horizontalMargin = [self.class spacingToMargin];
    CGFloat horizontalPadding = [self.class spacingOfText];
    
    self.shareToRepostTitleLabel = [[SSThemedLabel alloc] init];
    self.shareToRepostTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.shareToRepostTitleLabel.textColorThemeKey = kColorText1;
    self.shareToRepostTitleLabel.backgroundColor = [UIColor clearColor];
    self.shareToRepostTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.shareToRepostTitleLabel.font = [UIFont systemFontOfSize:[self.class fontSizeOfTitle]];
    self.shareToRepostTitleLabel.text = NSLocalizedString(@"站外分享同步到“关注”", nil);
    [self.contentView addSubview:self.shareToRepostTitleLabel];
    NSLayoutConstraint * labelLeftMarginConstraint =
    [NSLayoutConstraint constraintWithItem:self.shareToRepostTitleLabel
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.contentView
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1.0
                                  constant:horizontalMargin];
    NSLayoutConstraint * labelCenterYConstraint =
    [NSLayoutConstraint constraintWithItem:self.shareToRepostTitleLabel
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.contentView
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0
                                  constant:0];
    [self.contentView addConstraints:@[labelLeftMarginConstraint, labelCenterYConstraint]];
    
    self.shareToRepostSwitch = [[UISwitch alloc] init];
    self.shareToRepostSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.shareToRepostSwitch addTarget:self
                                 action:@selector(changeShareToRepost:)
                       forControlEvents:UIControlEventValueChanged];
    self.shareToRepostSwitch.on = [TTAccountManager currentUser].shareToRepost == TTShareToRepostStatusOpen;
    [self.contentView addSubview:self.shareToRepostSwitch];
    NSLayoutConstraint * switchRightMarginConstraint =
    [NSLayoutConstraint constraintWithItem:self.shareToRepostSwitch
                                 attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.contentView
                                 attribute:NSLayoutAttributeRight
                                multiplier:1.0
                                  constant:-horizontalMargin];
    NSLayoutConstraint * switchCenterYConstraint =
    [NSLayoutConstraint constraintWithItem:self.shareToRepostSwitch
                                 attribute:NSLayoutAttributeCenterY
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.contentView
                                 attribute:NSLayoutAttributeCenterY
                                multiplier:1.0
                                  constant:0];
    [self.contentView addConstraints:@[switchRightMarginConstraint, switchCenterYConstraint]];
    
    NSLayoutConstraint * componentPaddingConstraint =
    [NSLayoutConstraint constraintWithItem:self.shareToRepostSwitch
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                    toItem:self.shareToRepostTitleLabel
                                 attribute:NSLayoutAttributeRight
                                multiplier:1.0
                                  constant:horizontalPadding];
    [self.contentView addConstraint:componentPaddingConstraint];
}

- (void)changeShareToRepost:(UISwitch *)sender {
    [TTTrackerWrapper eventV3:@"forward_weitoutiao_switch_click"
                       params:@{@"switch_type":sender.on?@"on":@"off"}];
    BOOL isShareToRepost = sender.on;
    NSString * userID = [TTAccountManager currentUser].userID.stringValue;
    if (!isEmptyString(userID)) {//user id非空保护
        FRUgcPublishShareV1SetConfigRequestModel * request = [[FRUgcPublishShareV1SetConfigRequestModel alloc] init];
        request.share_repost = @(isShareToRepost);
        [[TTNetworkManager shareInstance] requestModel:request
                                              callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
                                                  if (!error) {
                                                      if ([userID isEqualToString:[TTAccountManager currentUser].userID.stringValue]) {//保证回调的时候是同一个账号
                                                          [TTAccountManager currentUser].shareToRepost = isShareToRepost?TTShareToRepostStatusOpen:TTShareToRepostStatusClose;
                                                      }
                                                  }
                                              }];
    }
}

@end
