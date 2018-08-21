//
//  TTNewFollowingResponseModel.h
//  Article
//
//  Created by lizhuoli on 17/1/8.
//
//

#import "JSONModel.h"

@protocol TTFollowingMergeResponseModel @end;
@protocol TTFollowingResponseModel @end;

@interface TTFollowingMergeResponseModel : JSONModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString<Optional> *userDescription;
@property (nonatomic, copy) NSString<Optional> *time;
@property (nonatomic, strong) NSNumber<Optional> *tips;
@property (nonatomic, copy) NSString<Optional> *tipsCount; // 聚合更新数
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *avatarURLString;

// 当前访问uid
@property (nonatomic, copy) NSString<Ignore> *visitorUID;

@end

@interface TTFollowingResponseModel : JSONModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString<Optional> *mediaID;
@property (nonatomic, strong) NSNumber<Optional> *isVerified;
@property (nonatomic, copy) NSString<Optional> *userAuthInfo;
@property (nonatomic, copy) NSString *avatarURLString;
@property (nonatomic, copy) NSString<Optional> *userDescription;
@property (nonatomic, copy) NSString<Optional> *userDecoration;
@property (nonatomic, copy) NSString<Optional> *tipsCount;
@property (nonatomic, copy) NSString<Optional> *midDescription;

// 当前访问uid
@property (nonatomic, copy) NSString<Ignore> *visitorUID;

@end

@interface TTNewFollowingResponseModel : JSONModel

@property (nonatomic, copy) NSString<Optional> *cursor;
@property (nonatomic, strong) NSNumber *hasMore;
@property (nonatomic, copy) NSArray<Optional, TTFollowingMergeResponseModel> *mergeData;
@property (nonatomic, copy) NSArray<Optional, TTFollowingResponseModel> *data;

@end
