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
@class FHDetailDataBaseExtraDetectiveModel;
@class FHRentDetailDataBaseExtraModel;
@interface FHDetailHalfPopLayer : UIView

@property(nonatomic , copy) void (^reportBlock)(id data);

-(void)showWithOfficialData:(FHDetailDataBaseExtraOfficialModel *)data;

-(void)showDetectiveData:(FHDetailDataBaseExtraDetectiveModel *)data;

-(void)showDealData:(FHRentDetailDataBaseExtraModel *)data;


@end

NS_ASSUME_NONNULL_END
