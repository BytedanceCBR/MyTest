//
//  TTDetailNatantRewardViewModel.h
//  Article
//
//  Created by 刘廷勇 on 16/4/29.
//
//

#import <JSONModel/JSONModel.h>
#import <Foundation/Foundation.h>

@protocol TTDetailNatantRewardUser @end

@interface TTDetailNatantRewardUser : JSONModel

@property (nonatomic, copy) NSString *avatarURL;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString<Optional> *userAuthInfo;

@end

@interface TTDetailNatantRewardViewModel : JSONModel

@property (nonatomic, strong) NSString *rewardOpenURL;
@property (nonatomic, strong) NSString *rewardListURL;
@property (nonatomic, strong) NSNumber *rewardNum;
@property (nonatomic, strong) NSArray<TTDetailNatantRewardUser> *rewardUserList;

@end
