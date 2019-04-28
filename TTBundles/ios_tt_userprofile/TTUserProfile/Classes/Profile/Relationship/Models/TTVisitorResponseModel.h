//
//  TTVisitorResponseModel.h
//  Article
//
//  Created by liuzuopeng on 9/5/16.
//
//

#import <Foundation/Foundation.h>
#import "TTResponseModel.h"


@class TTVisitorFormattedModel;
@class TTVisitorItemModel;
@class TTVisitorDataModel;
@class TTVisitorModel;


@protocol TTVisitorItemModel <NSObject>
@end

/**
 *  函数
 */
extern BOOL tt_isSameDayOfVisitorItemModel(TTVisitorItemModel *aModel1, TTVisitorItemModel *aModel2);


/**
 * @wiki: https://wiki.bytedance.com/pages/viewpage.action?pageId=62424459#id-账号合并后的用户和关系API-关注页内的兴趣列表
 */
@interface TTVisitorItemModel : TTResponseModel
@property (nonatomic, assign) NSUInteger status;
@property (nonatomic, assign) NSUInteger type;

@property (nonatomic, assign) NSUInteger gender;

@property (nonatomic,   copy) NSString<Optional> *user_id;
@property (nonatomic,   copy) NSString<Optional> *media_id;
@property (nonatomic,   copy) NSString<Optional> *screen_name;
@property (nonatomic,   copy) NSString<Optional> *verified_content;
@property (nonatomic,   copy) NSString<Optional> *avatar_url;
@property (nonatomic,   copy) NSString<Optional> *userDescription; // description
@property (nonatomic,   copy) NSString<Optional> *userAuthInfo; // 头条认证展现
@property (nonatomic,   copy) NSString<Optional> *userDecoration;

@property (nonatomic, assign) BOOL is_following;
@property (nonatomic, assign) BOOL is_followed;
@property (nonatomic, assign) BOOL ban_comment;

@property (nonatomic, strong) NSNumber<Optional> *create_time;
@property (nonatomic, strong) NSNumber<Optional> *last_visit_time;
@end


@interface TTVisitorDataModel : TTResponseModel
@property (nonatomic, assign) BOOL       has_more;
@property (nonatomic, strong) NSNumber<Optional> *cursor;
@property (nonatomic, strong) NSNumber<Optional> *list_count;         //本页返回的访客数量
@property (nonatomic, strong) NSNumber<Optional> *visit_device_count; //匿名访客数
@property (nonatomic, strong) NSNumber<Optional> *visit_count_total;  //历史访客总数
@property (nonatomic, strong) NSNumber<Optional> *visit_count_recent; //本次的访客数量

@property (nonatomic, strong) NSArray<Optional, TTVisitorItemModel> *users;
@end



@interface TTVisitorModel : TTResponseModel
@property (nonatomic,   copy) NSString<Optional>  *message;
@property (nonatomic, strong) TTVisitorDataModel<Optional> *data;

- (void)appendVisitorModel:(TTVisitorModel *)aModel;
/**
 * 最近无匿名用户来访
 */
- (BOOL)isRecentAnonymousEmpty;
/**
 * 最近无人来访
 */
- (BOOL)isRecentEmpty;
/**
 * 历史无人来访
 */
- (BOOL)isHistoryEmpty;
- (BOOL)hasMore;
/**
 * 总来访用户数
 */
- (NSInteger)totalCount;
/**
 * 本页返回的访客数量
 */
- (NSInteger)listCount;
/**
 * 匿名用户数
 */
- (NSInteger)anonymousTotalCount;
/**
 * 最近来访用户数
 */
- (NSInteger)recentTotalCount;
- (NSInteger)countOfNearest7Day;
- (NSNumber *)cursor;

- (TTVisitorFormattedModel *)toFormattedModel;
- (TTVisitorFormattedModel *)toFormattedModelForNearestNDays:(NSUInteger)days;
@end

