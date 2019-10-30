//
//  FHUGCShareManager.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/10/30.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

// 分享模型
@interface FHUGCShareInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *coverImage;
@property (nonatomic, copy , nullable) NSString *isVideo;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, copy , nullable) NSString *title;

@end

@interface FHUGCShareManager : NSObject

+ (instancetype)sharedManager;
@property (nonatomic, strong)   FHUGCShareInfoModel       *shareInfo;
@property(nonatomic , strong) NSDictionary *tracerDict; // 详情页基础埋点数据

@end

NS_ASSUME_NONNULL_END
