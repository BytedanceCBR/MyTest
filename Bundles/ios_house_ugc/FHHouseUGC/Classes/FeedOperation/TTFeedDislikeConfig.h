//
//  TTFeedDislikeConfig.h
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/20.
//

#import <Foundation/Foundation.h>
#import "FHFeedOperationWord.h"
#import "FHUGCConfigModel.h"
#import <FHFeedOperationView.h>

@class FHFeedOperationViewModel;
/// 新版 disklie 的远程配置项。参见：http://settings.byted.org/static/main/index.html#/app_settings/item_detail?id=725
@interface TTFeedDislikeConfig : NSObject

+ (BOOL)enableModernStyle;

+ (NSArray<NSDictionary *> *)reportOptions;

+ (NSDictionary *)textStrings;

+ (NSArray *)operationList;

//根据userId获取对应的操作列表
+ (NSArray<FHFeedOperationWord *> *)operationWordList:(NSString *)userId;

+ (NSArray<FHFeedOperationWord *> *)operationWordListWithPermission:(NSArray<FHUGCConfigDataPermissionModel> *)permission;

+ (NSArray<FHFeedOperationWord *> *)operationWordListWithViewModel:(FHFeedOperationViewModel *)viewModel;

@end
