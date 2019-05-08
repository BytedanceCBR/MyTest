//
//  DemoFilterItemView.h
//  Demo
//
//  Created by leo on 2018/11/16.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FHHouseBase/FHHouseBase.h>
#import "FHFilterItemView.h"
NS_ASSUME_NONNULL_BEGIN

@interface DemoFilterItemView : FHFilterItemView<FHFilterItem>
@property (nonatomic, strong) UILabel* label;
@end

NS_ASSUME_NONNULL_END
