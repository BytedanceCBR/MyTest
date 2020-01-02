//
//  FHDetailHalfPopLayer.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FHDetailDataBaseExtraOfficialModel;
@class FHDetailDataBaseExtraDetectiveModel,FHDetailDataBaseExtraDetectiveReasonInfo;
@class FHRentDetailDataBaseExtraModel;
@interface FHDetailHalfPopLayer : UIView

@property(nonatomic , copy) void (^reportBlock)(id data);
@property(nonatomic , copy) void (^feedBack)(NSInteger type , id data , void (^compltion)(BOOL success));
@property(nonatomic , copy) void (^dismissBlock)();

- (void)showWithOfficialData:(FHDetailDataBaseExtraOfficialModel *)data trackInfo:(NSDictionary *)trackInfo;

- (void)showDetectiveData:(FHDetailDataBaseExtraDetectiveModel *)data trackInfo:(NSDictionary *)trackInfo;

- (void)showDealData:(FHRentDetailDataBaseExtraModel *)data trackInfo:(NSDictionary *)trackInfo;

- (void)showDetectiveReasonInfoData:(FHDetailDataBaseExtraDetectiveReasonInfo *)data trackInfo:(NSDictionary *)trackInfo;

@end

NS_ASSUME_NONNULL_END
