//
//  FHMapSubwayPickerView.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHMapSubwayModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHMapSubwayPickerView : UIView

@property(nonatomic , copy) void (^chooseStation)(FHMapSubwayDataOptionModel * line , FHMapSubwayDataOptionOptionsModel *station);
@property(nonatomic , copy) void (^requestDataBlock)(FHMapSubwayDataModel *data);

-(void)showWithSubwayData:(FHMapSubwayDataModel *)data inView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
