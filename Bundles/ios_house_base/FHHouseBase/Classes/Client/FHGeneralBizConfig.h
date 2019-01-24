//
//  FHGeneralBizConfig.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "FHConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHGeneralBizConfig : NSObject
@property (nonatomic, strong) FHConfigDataModel *configCache;

- (void)updataCurrentConfigCache;

- (void)saveCurrentConfigCache:(FHConfigModel *)configValue;

- (void)saveCurrentConfigDataCache:(FHConfigDataModel *)configValue;

- (void)updateUserSelectDiskCacheIndex:(NSNumber *)indexNum;

- (NSNumber *)getUserSelectTypeDiskCache;

- (void)onStartAppGeneralCache;

- (FHConfigDataModel *)getGeneralConfigFromLocal;

- (BOOL)isSavedSearchConfig;

@end

NS_ASSUME_NONNULL_END
