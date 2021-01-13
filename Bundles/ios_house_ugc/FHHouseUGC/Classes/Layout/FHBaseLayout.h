//
//  FHBaseLayout.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/12/14.
//

#import <Foundation/Foundation.h>
#import "FHLayoutItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHBaseLayout : NSObject

@property(nonatomic ,assign) CGFloat height;

//不依赖数据的变量初始化，只初始化一次
- (void)commonInit;
//依赖数据的变量更新
- (void)updateLayoutWithData:(id)data;

@end

NS_ASSUME_NONNULL_END
