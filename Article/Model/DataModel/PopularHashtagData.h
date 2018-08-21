//
//  PopularHashtagData.h
//  Article
//
//  Created by lipeilun on 2018/1/17.
//

#import "ExploreOriginalData.h"

@interface PopularHashtagData : ExploreOriginalData
@property (nonatomic, copy) NSString *hashtagPrimaryID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSDictionary *showMore;
@property (nonatomic, copy) NSDictionary *icon;
@property (nonatomic, copy) NSArray *forumList;

//转换格式的话题列表
@property (nonatomic, copy) NSArray<FRForumStructModel *> *forumModelArray;

+ (PopularHashtagData *)objectForCategory:(NSString *)categoryID uniqueID:(NSString *)uniqueID;

+ (PopularHashtagData *)updateWithDictionary:(NSDictionary *)dictionary uniqueID:(NSString *)uniqueID;

- (NSString *)showMoreText;

- (NSString *)showMoreSchema;

- (NSString *)dayIconURL;

- (NSString *)nightIconURL;

@end
