//
//  FHGeneralBizConfig.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "FHConfigModel.h"
#import <YYCache/YYCache.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kFHPhoneNumberCacheKey;
extern NSString *const kFHPLoginhoneNumberCacheKey;
extern NSString *const kFHFindHousePhoneNumberCacheKey;

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

- (NSString *)readLocalDefaultCityNamePreviousVersion;

- (YYCache *)sendPhoneNumberCache;

- (YYCache *)subscribeHouseCache;
//保存已经显示的房源详情反馈弹窗
- (YYCache *)detailFeedbackCache;
//疫情反馈专题底部tabimage
- (YYCache *)epidemicSituationCache;
//帮我找房手机号缓存
- (YYCache *)findHousePhoneNumberCache;

@end

NS_ASSUME_NONNULL_END
