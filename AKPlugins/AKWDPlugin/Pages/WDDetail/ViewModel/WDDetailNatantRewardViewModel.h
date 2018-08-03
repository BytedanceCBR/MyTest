//
//  WDDetailNatantRewardViewModel.h
//  Article
//
//  Created by 张延晋 on 17/11/16.
//
//

#import <JSONModel/JSONModel.h>
#import <Foundation/Foundation.h>

@protocol WDDetailNatantRewardUser @end

@interface WDDetailNatantRewardUser : JSONModel

@property (nonatomic, copy) NSString *avatarURL;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString<Optional> *userAuthInfo;
@property (nonatomic, copy) NSString<Optional> *userDecoration;

@end

@interface WDDetailNatantRewardViewModel : JSONModel

@property (nonatomic, strong) NSString *rewardOpenURL;
@property (nonatomic, strong) NSString *rewardListURL;
@property (nonatomic, strong) NSNumber *rewardNum;
@property (nonatomic, strong) NSArray<WDDetailNatantRewardUser> *rewardUserList;

@end
