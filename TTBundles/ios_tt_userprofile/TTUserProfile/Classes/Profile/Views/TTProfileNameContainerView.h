//
//  TTProfileNameContainerView.h
//  Article
//
//  Created by liuzuopeng on 9/5/16.
//
//

#import <Foundation/Foundation.h>
#import "SSThemed.h"
#import "TTImageView.h"



@class TTAlphaThemedButton;
@interface TTNameContainerView : SSThemedView
@property (nonatomic, strong) SSThemedLabel     *nameLabel;
@property (nonatomic, strong) SSThemedLabel     *showInfoLabel;
@property (nonatomic, strong) TTAlphaThemedButton *followersButton;
@property (nonatomic, strong) TTAlphaThemedButton *visitorButton;
//@property (nonatomic, strong) TTVerifyIconImageView *verifiedUserImageView;
@property (nonatomic, strong) SSThemedImageView *toutiaohaoUserImageView;
@property (nonatomic, strong) SSThemedImageView *rightArrowImageView;
//@property (nonatomic, strong) TTImageView *addAuthImageView;  //普通用户认证入口button
//@property (nonatomic, strong) SSThemedLabel *addAuthLabel;  //头条号用户认证入口label

- (void)refreshContainerView;
@end

