//
//  FHMapSubwayPickerView.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "FHMapSubwayModel.h"
#import <FHHouseBase/FHSearchConfigModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMapSubwayPickerView : UIView

@property(nonatomic , copy) void (^chooseStation)(FHSearchFilterConfigOption * line , FHSearchFilterConfigOption *station);
//@property(nonatomic , copy) void (^requestDataBlock)(FHMapSubwayDataModel *data);

@property(nonatomic , copy) void (^dismissBlock)();

-(void)showWithSubwayData:(FHSearchFilterConfigOption *)data inView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
