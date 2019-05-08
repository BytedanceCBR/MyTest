//
//  ConditionSelectView.h
//  Demo
//
//  Created by leo on 2018/11/17.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FHHouseBase/FHHouseBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConditionSelectView : UIView<ConditionSelectPanelDelegate>
-(instancetype)initWithName:(NSString*)name;
@end

NS_ASSUME_NONNULL_END
