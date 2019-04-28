//
//  TTPersonalHomeSinglePlatformFollowersInfoModel.h
//  Article
//
//  Created by 邱鑫玥 on 2018/1/9.
//

#import "TTResponseModel.h"

@interface TTPersonalHomeSinglePlatformFollowersInfoModel : TTResponseModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, strong) NSNumber *fansCount;
@property (nonatomic, copy) NSString *openUrl;
@property (nonatomic, copy) NSString *appleId;
@property (nonatomic, copy) NSString *downloadUrl;
@property (nonatomic, copy) NSString *appName;

@end
