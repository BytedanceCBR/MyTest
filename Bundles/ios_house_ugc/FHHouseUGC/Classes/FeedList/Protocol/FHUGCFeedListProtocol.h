//
//  FHUGCFeedListProtocol.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/9/15.
//

#import <Foundation/Foundation.h>
#import "FHUGCConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHUGCFeedListProtocol <NSObject>

@optional
//传入以后点击三个点以后显示该数组的内容
@property(nonatomic, strong ,nullable) NSArray<FHUGCConfigDataPermissionModel> *operations;

@end

NS_ASSUME_NONNULL_END
