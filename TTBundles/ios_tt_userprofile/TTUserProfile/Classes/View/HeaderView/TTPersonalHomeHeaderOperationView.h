//
//  TTPersonalHomeHeaderOperationView.h
//  Article
//
//  Created by 王迪 on 2017/3/13.
//
//

#import "SSThemed.h"
#import "TTAsyncCornerImageView.h"
#import "TTPersonalHomeUserInfoResponseModel.h"
#import "TTFollowThemeButton.h"
#import "TTPersonalHomeFollowButton.h"
#import "TTPersonalHomeIconView.h"

@interface TTPersonalHomeHeaderOperationView : SSThemedView

@property (nonatomic, weak) TTPersonalHomeIconView *iconView;
@property (nonatomic, weak) SSThemedImageView *sanjiaoIcon;

@property (nonatomic, weak) SSThemedButton *beFollowedBtn;
@property (nonatomic, weak) TTFollowThemeButton *followButton;
@property (nonatomic, weak) TTPersonalHomeFollowButton *unBlockView;
@property (nonatomic, weak) SSThemedButton *recommendViewOperationBtn;

//@property (nonatomic, weak) SSThemedButton *certificationBtn;
@property (nonatomic, weak) TTPersonalHomeFollowButton *profileView;

@property (nonatomic, strong) TTPersonalHomeUserInfoDataResponseModel *infoModel;
@property (nonatomic, assign) BOOL hasVerified;
- (void)setPrivateMessage;
- (void)setVerified;
- (void)clearVerified;

- (void)recommendViewOperationBtnAnimationWithSpread:(BOOL)isSpread;

@end
