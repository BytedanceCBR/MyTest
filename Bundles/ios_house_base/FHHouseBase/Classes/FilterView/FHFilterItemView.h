//
//  FHFilterItemView.h
//  FHHouseBase
//
//  Created by leo on 2018/11/17.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterItemBar.h"
#import "ConditionSelectPanelDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHFilterItemView : UIView<FHFilterItem>
@property (nonatomic, weak) UIView<ConditionSelectPanelDelegate>* conditionSelectPanel;
-(instancetype)initWithConditionSelectPanel:(UIView*)conditionSelectPanel;
@end

NS_ASSUME_NONNULL_END
