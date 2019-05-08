//
//  TTCommentStore.h
//  Article
//
//  Created by muhuai on 16/8/21.
//
//

#import <Foundation/Foundation.h>
#import "TTRedux.h"
#import "TTMomentDetailLifeCycleReducer.h"
#import "TTMomentDetailStore.h"
#import "TTMomentDetailAction.h"
#import "TTMomentDetailMiddleware.h"
#import "TTCommentDetailModel.h"
#import "TTCommentDetailCellLayout.h"
#import <TTBatchItemAction/DetailActionRequestManager.h>


@interface TTMomentDetailIndependenceState : State;  //每个详情页面的state  TODO://名字起得不好....

@property (nonatomic, copy) NSString *serviceID; // 评论服务所属 serviceID, 评论接口使用
@property (nonatomic, copy) NSString *commentID;
@property (nonatomic, copy) NSString *stickID;
@property (nonatomic, copy) NSString *uniqueID;

@property (nonatomic, strong) TTCommentDetailModel *detailModel;
@property (nonatomic, strong) id<TTCommentModelProtocol> commentModel; //从评论区进入时会带上commentModel

//cell layout
@property (nonatomic, strong) NSMutableArray<TTCommentDetailCellLayout *> *hotCommentLayouts;
@property (nonatomic, strong) NSMutableArray<TTCommentDetailCellLayout *> *allCommentLayouts;
@property (nonatomic, strong) NSMutableArray<TTCommentDetailCellLayout *> *stickCommentLayouts;

//cell model
@property (nonatomic, strong) NSMutableArray<TTCommentDetailReplyCommentModel *> *hotComments;//热门
@property (nonatomic, strong) NSMutableArray<TTCommentDetailReplyCommentModel *> *allComments;//全部
@property (nonatomic, strong) NSMutableArray<TTCommentDetailReplyCommentModel *> *stickComments;//置顶

//datasource
@property (nonatomic, strong) NSArray <NSArray<TTCommentDetailReplyCommentModel *> *> *totalComments;//dataSource
@property (nonatomic, strong) NSArray <NSArray<TTCommentDetailCellLayout *> *> *totalCommentLayouts;

//暂存的置顶model, 用于置顶评论的最后一次请求
@property (nonatomic, strong) NSArray <TTCommentDetailReplyCommentModel *> *stashStickComments;


@property (nonatomic, strong) DetailActionRequestManager *commentActionManager;
@property (nonatomic, assign) BOOL hasMoreStickComment; //置顶评论请求完了 再去请求普通评论
@property (nonatomic, assign) BOOL hasMoreComment;
//@property (nonatomic, assign) BOOL isLoadingMoment;
@property (nonatomic, assign) BOOL isLoadingComment;
@property (nonatomic, assign) BOOL isFailedLoadComment;
@property (nonatomic, assign) BOOL needShowNetworkErrorPage;
@property (nonatomic, strong) TTCommentDetailReplyCommentModel *defaultRelyModel;
//@property (nonatomic, assign) BOOL isLoadingDigList;
//@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, strong) NSIndexPath *needMarkedIndexPath;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger cellWidth;
@property (nonatomic, assign) TTCommentDetailSourceType from;
@property (nonatomic, assign) BOOL isFromMessage; //是否通过消息进入, 比如评论的高亮cell, 底部toolbar
@end;

@interface TTMomentDetailStore : Store
@property (nonatomic, strong) TTMomentDetailIndependenceState *state;

@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, strong) NSDictionary *logPb;


+ (instancetype)sharedStore;

@end
