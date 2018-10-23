//
//  TTHashtagCardData.h
//  Article
//
//  Created by lipeilun on 2017/11/2.
//

#import <ExploreOriginalData.h>

@interface TTHashtagForumInfoModel : NSObject
@property (nonatomic, copy) NSString *forum_id;
@property (nonatomic, copy) NSString *forum_name;
@property (nonatomic, copy) NSString *concern_id;
@property (nonatomic, copy) NSString *avatar_url;
@property (nonatomic, copy) NSString *banner_url;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *schema;
@property (nonatomic, copy) NSString *share_url;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, assign) NSInteger talk_count;//讨论数
@property (nonatomic, assign) NSInteger read_count;//阅读数
@property (nonatomic, assign) NSInteger follower_count;
+ (TTHashtagForumInfoModel *)generationForumInfoModelWithDict:(NSDictionary *)dict;
@end

@interface TTHashtagCardData : ExploreOriginalData
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSDictionary *forum;

- (TTHashtagForumInfoModel *)forumModel;

@end
