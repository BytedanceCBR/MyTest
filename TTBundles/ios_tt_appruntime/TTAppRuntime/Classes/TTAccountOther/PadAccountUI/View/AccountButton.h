//
//  AccountButton.h
//  ShareOne
//
//  Created by 剑锋 屠 on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



@class TTThirdPartyAccountInfoBase;
@class AccountButton;
@protocol AccountButtonDelegate <NSObject>
@optional
- (void)accountButtonClicked:(AccountButton *)button
          accountDisplayName:(NSString *)displayName accountName:(NSString *)name;
@end



typedef enum AccountButtonState {
    AccountButtonStateNormal,
    AccountButtonStateHighlight
} AccountButtonState;


@interface AccountButton : UIView

- (instancetype)initWithFrame:(CGRect)frame
                  accountInfo:(TTThirdPartyAccountInfoBase *)tAccount;

@property (nonatomic, strong, readonly) TTThirdPartyAccountInfoBase *accountInfo;
@property (nonatomic,   weak) NSObject<AccountButtonDelegate> *delegate;
@property (nonatomic, assign) BOOL displayName;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, assign) UIEdgeInsets contentInsets;

- (void)setCustomAlpha:(float)alpha;
@end

