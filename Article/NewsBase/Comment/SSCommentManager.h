//
//  SSCommentManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-8-2.
//
//

#import <Foundation/Foundation.h>
#import "SSCommentModel.h"
#import "TTGroupModel.h"
#import "Article.h"

///*
// * 评论列表数据类型
// */
//typedef NS_ENUM(NSInteger, SSCommentListDataType)
//{
//    SSCommentListDataTypeComment = 1,       //评论
//    SSCommentListDataTypeMoment,            //嵌入式动态
//    SSCommentListDataTypeAds,               //嵌入式广告
//};

//added 4.9:评论列表增加了帖子和广告，offset针对评论，减少此值防止评论遗漏
#define kLoadMoreOffsetCount 15
#define kLoadMoreFetchCount  20

#define kChangedFlagFailed  @2
#define kChangedFlagDone    @1

#define kChangedFlagDoneForFirstLoad    @3  //第一次加载评论完成
//added 4.9
#define kChangedFlagDoneForLoadMore     @4  //加载更多评论完成

#define kCommentManagerFirstLoadConditionTopCommentIDKey @"kCommentManagerFirstLoadConditionTopCommentIDKey"

////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface SSCommentManagerObject : NSObject
@property(nonatomic, strong)NSNumber * offset;
//added from 4.9
/**
 *  此评论列表tab名称及本次进入详情页是否已刷新过
 **/
@property(nonatomic, copy)NSString * tabName;
@property(nonatomic, assign)BOOL hasReload;

- (NSMutableArray *)queryCommentModels;

- (void)appendCommentModels:(NSArray *)models;
- (void)insertCommentModelToTop:(SSCommentModel *)model;
- (void)resetDatas;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol SSCommentManagerDelegate;

@interface SSCommentManager : NSObject

@property(nonatomic, assign)BOOL loading;       //begin status is NO
@property(nonatomic, assign)BOOL bannComment;   //禁言
@property(nonatomic, assign)BOOL goTopicDetail; //added 4.6:是否允许查看评论的动态详情页
@property(nonatomic, assign, readonly)BOOL detailNoComment;//详情页不显示评论
@property(nonatomic, assign)BOOL forceShowComment;//开始为NO， 如果为YES，则忽略detailNoComment

@property(nonatomic, strong)NSNumber * changedFlag;//KVO the value, notify change

//added from 4.9
/**
 *  评论列表tab名称
 **/
@property(nonatomic, strong)NSArray *commentTabs;
/**
 *  评论tabs的Dictionary<tab_index:SSCommentManagerObject> 替代原来三个SSCommentManagerObject
 **/
@property(nonatomic, strong)NSMutableDictionary *commentManagerObjects;
/**
 *  当前展示的评论tabIndex（后台返回tabs中的index）替代原来的managerObjectType
 **/
@property(nonatomic, assign)NSInteger curTabIndex;

@property(nonatomic, assign)NSUInteger commentsCount;//所有评论的数量

@property(nonatomic, assign)BOOL shouldShowAddForum;//发评论是否显示添加话题

@property(nonatomic, strong, readonly)TTGroupModel *groupModel;

@property(nonatomic, weak)id<SSCommentManagerDelegate>delegate;

//强制当前object可以被loadMore
- (void)forceCurrentObjectShouldLoadMore;

//文章详情页webView的评论模版
+ (NSString *)detailCommentTemplate;
//api返回的json转换为comment
+ (SSCommentModel *)commentDictToModel:(NSDictionary *)dict groupModel:(TTGroupModel *)groupModel;
- (void)removeCommentForModel:(SSCommentModel *)model;
- (void)loadCommentWithGroupModel:(TTGroupModel *)groupModel userInfo:(NSDictionary *)userInfo;   //第一次请求
- (void)tryLoadCommentWithGroupModel:(TTGroupModel *)groupModel userInfo:(NSDictionary *)userInfo;   //第一次请求, 如果有数据， 则不请求
- (void)loadCommentWithArticle:(Article *)article userInfo:(NSDictionary *)userInfo;   //第一次请求
//- (void)tryLoadCommentWithArticle:(Article *)article userInfo:(NSDictionary *)userInfo;   //第一次请求, 如果有数据， 则不请求
- (void)loadMore;   //加载更多
- (void)reloadCommentWithTagIndex:(NSInteger)tagIndex;

//插入评论并置顶
- (void)insertCommentDictToTop:(NSDictionary*)commentDict;
- (void)insertCommentModelToTop:(SSCommentModel *)model;

- (void)cancelCurrentLoad;
- (void)cancelCurrentLoadAndReset;
- (void)clearDataAndUI;

- (NSMutableArray *)curCommentModels;
- (BOOL)needLoadingUpdateCommentModels;
- (BOOL)needLoadingMoreCommentModels;
- (BOOL)requestRaiseError;

- (SSCommentManagerObject *)currentCommentManagerObject;
- (NSString *)currentCommentTabName;
- (NSUInteger)numberOfRowsForCurCommentManagerObject;

- (Article *)curentArticle;

@end

@protocol SSCommentManagerDelegate <NSObject>

@optional
- (void)articleInfoManager:(SSCommentManager *)manager refreshCommentsCount:(NSUInteger)commentsCount;

- (void)articleInfoManager:(SSCommentManager *)manager shouldShowAddForum:(BOOL)shouldShow;
@end
