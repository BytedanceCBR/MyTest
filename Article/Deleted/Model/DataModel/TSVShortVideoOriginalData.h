//
//  TSVShortVideoOriginalData.h
//  Article
//
//  Created by 王双华 on 2017/5/24.
//
//

#import "ExploreOriginalData.h"
#import "TTShortVideoModel.h"
#import "TTImageInfosModel.h"

extern NSString * _Nullable const kTSVShortVideoDeleteNotification;
extern NSString * _Nullable const kTSVShortVideoDeleteUserInfoKeyGroupID;

@interface TSVShortVideoOriginalData : ExploreOriginalData

@property (nullable, nonatomic, copy) NSString *primaryID;
@property (nullable, nonatomic, copy) NSDictionary *originalDict;
@property (nullable, nonatomic, strong) TTShortVideoModel *shortVideo;
@property (nullable, nonatomic, strong) NSArray *filterWords;

+ (NSString *_Nonnull)primaryIDByUniqueID:(int64_t)uniqueID
                         listType:(NSUInteger)listType;

@end
