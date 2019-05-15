//
//  SSFeedbackManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-1-6.
//
//

#import <Foundation/Foundation.h>
#import "SSFeedbackModel.h"

#define kSSFeedbackManagerFetchedDataNotification @"kSSFeedbackManagerFetchedDataNotification"

#define fetchCount 50

@protocol SSFeedbackManagerDelegate;

@interface SSFeedbackManager : NSObject

@property(nonatomic, weak) id<SSFeedbackManagerDelegate> delegate;

//统计
@property (nonatomic,copy) NSDictionary *trackerInfo;

/**
 截屏时页面的URL
 */
@property(nonatomic, strong) NSString *snapshotURL;

/**
 截屏时页面的DOM
 */
@property(nonatomic, strong) NSString *snapshotDOM;

@property(nonatomic, strong) NSDate *snapshotDate;

+ (SSFeedbackManager *)shareInstance;

+ (BOOL)hasNewFeedback;
+ (void)setHasNewFeedback:(BOOL)hasNew;

//保存本次用户反馈
+ (void)saveFeedbackModels:(NSArray *)ary;
//取出上次保存的用户反馈
+ (NSArray *)recentFeedbackModels;
//获取之前保存的默认项（位于列表最上面）
+ (SSFeedbackModel *)queryDefaultFeedbackModel;
//保存用户的联系方式
+ (void)saveDefaultContactString:(NSString *)string;
+ (NSString *)defaultContactString;

+ (NSString *)needPostImgURI;
//传nil， 清除
+ (void)saveNeedPostImgURI:(NSString *)uri;

+ (UIImage *)needPostImg;
//传nil， 清除
+ (void)saveNeedPostImg:(UIImage *)image;

+ (NSString *)needPostMsg;
//传nil， 清除
+ (void)saveNeedPostMsg:(NSString *)msg;

- (void)checkHasNewFeedback;
- (void)startFetchComments:(BOOL)isLoadMore contextID:(NSString *)cId;
- (void)startPostFeedbackContent:(NSString *)contentStr userContact:(NSString *)contactStr imgURI:(NSString *)URI backgorundImgURI:(NSString *)backURI imageCreateDate:(NSDate *)imageCreateDate;

/**
 自定义post参数的feedback api
 会默认带上通用参数
 如果postParam里传入了相同的key, 则postParam会覆盖

 @param postParam 自定义post参数
 */
- (void)startPostFeedbackWithCustomPostParam:(NSDictionary *)postParam;

/**
 进入反馈页的当前常见问题id
 */
+ (void)updateCurQuestionID:(nullable NSString *)questionID;
@end

@protocol SSFeedbackManagerDelegate <NSObject>

@optional

- (void)feedbackManager:(SSFeedbackManager *)manager fetchedNewModels:(NSArray *)feedbackModels userInfo:(NSDictionary *)userinfo error:(NSError *)error;
- (void)feedbackManager:(SSFeedbackManager *)manager postMsgUserInfo:(NSDictionary *)dict error:(NSError *)error;
@end
