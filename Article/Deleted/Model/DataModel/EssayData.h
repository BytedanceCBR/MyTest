//
//  EssayData.h
//  Essay
//
//  Created by 于天航 on 12-9-4.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "ExploreOriginalData.h"
#import "TTImageInfosModel.h"

typedef NS_ENUM(NSInteger, EssayUGCStatus) {
    EssayUGCStatusPosted = 1,
    EssayUGCStatusReviewed = 2,
    EssayUGCStatusRecommended = 3,
    EssayUGCStatusDeleted = 0
};

@interface EssayData : ExploreOriginalData

@property (nonatomic, retain) NSDictionary *comment;
@property (nonatomic, retain) NSArray * godComments;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * createTime;
@property (nonatomic, retain) NSString * dataURL;
@property (nonatomic, retain) NSDictionary * largeImageDict;
@property (nonatomic, retain) NSDictionary * middleImageDict;
@property (nonatomic, retain) NSString * profileImageURL;
@property (nonatomic, retain) NSString * screenName;
/**
 *  UGC状态 1：已发布，2：已审核，3：已推荐，0：已删除
 */
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * statusDesc;

/**
 *  通过largeImageDict转换的大图Model
 *
 *  @return
 */
- (TTImageInfosModel *)largeImageModel;
/**
 *  通过middleImageDict转换的大图Model
 *
 *  @return
 */
- (TTImageInfosModel *)middleImageModel;

- (NSString *)commentContent;

- (NSArray *)godCommentObjArray;

@end
