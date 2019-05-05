//
//  ArticleShareManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-3-15.
//
//

#import <Foundation/Foundation.h>
#import "Article.h"
#import "TTActivityShareManager.h"
#import "PGCAccount.h"
#import "ExploreEntry.h"
#import "WDQuestionEntity.h"
#import "WDAnswerEntity.h"
#import "TTCommentDetailModel.h"
#import "HuoShan.h"

@class TTVFeedItem;
@class FRConcernEntity;
@class FRThreadEntity;
@interface TTShareModel : NSObject
@property (nonatomic ,strong, nullable)NSNumber *adID;
@property(nonatomic, copy, nullable)NSString *shareURL;
@property (nonatomic, copy, nullable)   NSString *downloadURL;
@property(nonatomic, strong, nullable) TTGroupModel *groupModel;
@property (nonatomic, retain, nullable) NSString *mediaName;//订阅号名称
@property (nonatomic, retain, nullable) NSString *title;
@property (nonatomic, retain, nullable) NSString *abstract;
@property (nonatomic, copy, nullable) NSString *content;
@property (nonatomic, nullable) NSNumber *commentCount;
@property (nonatomic, nullable) TTImageInfosModel *infosModel;
+ (TTShareModel *_Nullable)shareModelWithFeedItem:(TTVFeedItem *_Nullable)item;
@end


@interface ArticleShareManager : NSObject

+ (nonnull ArticleShareManager *)shareManager;

+ (nonnull NSMutableArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager setHuoshanCondition:(nonnull HuoShan *)huoshan;

+ (nonnull NSMutableArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager setArticleCondition:(nonnull Article *)article adID:(nullable NSNumber *)adID;

+ (nonnull NSMutableArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager setArticleCondition:(nonnull Article *)article adID:(nullable NSNumber *)adID showReport:(BOOL)showReport;

+ (nonnull NSMutableArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager setArticleCondition:(nonnull Article *)article adID:(nullable NSNumber *)adID showReport:(BOOL)showReport withQQ:(BOOL)qq;

+ (nonnull NSMutableArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager setNativeGalleryImage:(nullable UIImage *)image webGalleryURL:(nullable NSString *)galleryURL;

+ (nonnull NSMutableArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager pgcAccount:(nonnull PGCAccount *)account;

+ (nonnull NSMutableArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager exploreEntry:(nonnull ExploreEntry *)entry;

+ (nonnull NSMutableArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager setWapConditionWithTitle:(nullable NSString *)title desc:(nullable NSString *)desc url:(nullable NSString *)url imageUrl:(nullable NSString *)imageUrl;

+ (nonnull NSMutableArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager shareInfo:(nonnull NSDictionary *)shareInfo showReport:(BOOL)report;

+ (nonnull NSMutableArray *)shareActivityManager:(nullable TTActivityShareManager *)manager shareModel:(nullable TTShareModel *)shareModel showReport:(BOOL)showReport;
+ (nonnull NSMutableArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager shareInfo:(nonnull NSDictionary *)shareInfo showReport:(BOOL)report withQQ:(BOOL)qq;

/**
 *  个人中心的分享Activity
 *
 *  @param manager       activity实例
 *  @param data          分享的数据
 *  @param isAccountUser 是否为登录的用户
 *
 *  @return 当前所有的分享activity item
 */
+ (nullable NSArray *)shareActivityManager:(nonnull TTActivityShareManager *)manager profileShareObject:(nullable NSDictionary *)data isAccountUser:(BOOL)loginUser;

@end
