//
//  TTForumPostThreadStatusViewModel.h
//  Article
//
//  Created by 徐霜晴 on 16/10/9.
//
//

#import <UIKit/UIKit.h>
#import "TTPostThreadTask.h"
#import <TTBaseLib/NSObject+TTAdditions.h>

typedef void (^TTPostThreadTaskProgressBlock)(CGFloat progress);

typedef NS_ENUM(NSUInteger, TTForumPostThreadFailureWording) {
    TTForumPostThreadFailureWordingNetworkError,
    TTForumPostThreadFailureWordingServiceError,
    TTForumPostThreadFailureWordingVideoNotFound,
};


@interface TTPostThreadTaskStatusModel : NSObject

@property (nonatomic, assign) TTPostTaskType taskType;
@property (nonatomic, assign) TTThreadRepostType repostType;
@property (nonatomic, assign) TTPostTaskStatus status;
@property (nonatomic, assign) TTForumPostThreadFailureWording failureWordingType;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *titleRichSpan;
@property (nonatomic, strong) UIImage *coverImage;

@property (nonatomic, assign) CGFloat uploadingProgress;
@property (nonatomic, assign) int64_t fakeThreadId;
@property (nonatomic, copy) NSString *concernID;
@property (nonatomic, copy) NSDictionary *extraTrack;

- (instancetype)initWithPostThreadTask:(TTPostTask *)task;

- (void)addProgressBlock:(TTPostTaskProgressBlock)progressBlock;
- (void)removeProgressBlock:(TTPostTaskProgressBlock)progressBlock;
- (NSArray <TTPostTaskProgressBlock> *)getProgressBlocks;

@end


@interface TTForumPostThreadStatusViewModel : NSObject<Singleton>

@property (nonatomic, strong, readonly) NSMutableArray <TTPostThreadTaskStatusModel *> * mainTaskStatusModels;
@property (nonatomic, strong, readonly) NSMutableArray <TTPostThreadTaskStatusModel *> *followTaskStatusModels;
@property (nonatomic, strong, readonly) NSMutableArray <TTPostThreadTaskStatusModel *> * weitouTiaoTaskStatusModels;
@property (nonatomic, assign) BOOL isEnterFollowPageFromPostNotification;
@property (nonatomic, assign) BOOL isEnterHomeTabFromPostNotification;

@property (nonatomic, copy)     dispatch_block_t       statusChangeBlk;// 状态发生变化

- (BOOL)isTaskConcernIdValid:(NSString *)concernID;
- (NSMutableArray *)modelsArrayWithConcernID:(NSString *)concernID;
- (NSString *)modelNamesArrayWithConcernID:(NSString *)concernID;


@end


