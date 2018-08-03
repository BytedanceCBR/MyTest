//
//  TTRedPacketDetailBaseView.h
//  Article
//
//  Created by Jiyee Sheng on 8/3/17.
//
//


#import "SSThemed.h"

@class ExploreAvatarView;

typedef void(^RPDetailDismissBlock)();

@interface TTRedPacketDetailBaseViewModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *money;
@property (nonatomic, strong) NSString *withdrawUrl;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *listTitle;


@end


@interface TTRedPacketDetailBaseView : SSThemedView

@property (nonatomic, strong) SSThemedView *navBar;
@property (nonatomic, strong) SSThemedButton *navBarLeftButton;
@property (nonatomic, strong) SSThemedLabel *navBarTitleLabel;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SSThemedView *curveView;

@property (nonatomic, strong) ExploreAvatarView *avatarView;
@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) SSThemedView *contentView;
@property (nonatomic, strong) SSThemedLabel *nameLabel; // 姓名
@property (nonatomic, strong) SSThemedLabel *descriptionLabel; // 红包描述
@property (nonatomic, strong) SSThemedLabel *moneyLabel; // 面值
@property (nonatomic, strong) SSThemedButton *withdrawButton; // 提现
@property (nonatomic, assign) BOOL fromPush;
@property (nonatomic, copy) RPDetailDismissBlock dismissBlock;
- (void)configWithViewModel:(TTRedPacketDetailBaseViewModel *)viewModel;

@end

