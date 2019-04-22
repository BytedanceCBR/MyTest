//
//  AKRedPacketDetailBaseView.h
//  Article
//
//  Created by 冯靖君 on 2018/3/8.
//

#import <UIKit/UIKit.h>
#import <SSThemed.h>
#import "AKShareView.h"

@class AKRedPacketOptionalLoginView;
typedef void(^RPDetailDismissBlock)();

@interface AKRedPacketDetailBaseViewModel : NSObject

@property (nonatomic, copy) NSString *amount;
@property (nonatomic, assign) NSInteger withdrawMinAmount;
@property (nonatomic, assign) NSInteger inviteBonusAmount;
@property (nonatomic, copy) NSString *openURL;
@property (nonatomic, copy) NSDictionary *shareInfo;

@end

@interface AKRedPacketDetailBaseView : SSThemedView

@property (nonatomic, strong) SSThemedView *navBar;
@property (nonatomic, strong) SSThemedButton *navBarLeftButton;
@property (nonatomic, strong) SSThemedLabel *navBarTitleLabel;

@property (nonatomic, strong) SSThemedView *curveView;
@property (nonatomic, strong) CAGradientLayer *curveLayer;
@property (nonatomic, strong) SSThemedView *curveBackView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) SSThemedView *contentView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;         // 姓名
@property (nonatomic, strong) SSThemedLabel *moneyLabel;        // 金额
@property (nonatomic, strong) SSThemedLabel *tipLabel;          // 金额提示语
@property (nonatomic, strong) UIButton *wechatLoginButton;      //微信登录按钮
@property (nonatomic, strong) UIButton *openURLButton;          //跳转到其他页面按钮
@property (nonatomic, strong) AKShareView *shareView;           //分享页
@property (nonatomic, strong) AKRedPacketOptionalLoginView *bottomLoginView; //底部登录

@property (nonatomic, copy) RPDetailDismissBlock dismissBlock;

- (void)configWithViewModel:(AKRedPacketDetailBaseViewModel *)viewModel;

@end
