//
//  AccountManagerView.h
//  Essay
//
//  Created by 于天航 on 12-9-4.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSViewBase.h"

@class AccountManagerView;

@protocol AccountManagerViewDelegate <NSObject>
@optional
- (void)accountViewFinishedLogoutUser:(AccountManagerView *)accountView;
- (BOOL)accountManagerView:(AccountManagerView *)view authorityDelegate:(id)delegate userInfo:(id)userInfo;
@end



@interface AccountManagerView : SSViewBase
@property (nonatomic,     weak) NSObject<AccountManagerViewDelegate> *delegate;
@property (nonatomic, readonly) BOOL backButtonDisabled;
@end
