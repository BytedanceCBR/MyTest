//
//  WapData.h
//  Article
//
//  Created by Chen Hong on 15/3/3.
//
//

#import <Foundation/Foundation.h>
#import "ExploreOriginalData.h"


@interface WapData : ExploreOriginalData

//@property (nonatomic, retain) NSNumber * cellHeight;
@property (nonatomic, retain) NSString * dataUrl;
@property (nonatomic, retain) NSString * baseUrl;
@property (nonatomic, retain) NSString * templateUrl;
@property (nonatomic, retain) NSString * templateMD5;
@property (nonatomic, retain) NSString * dataCallback;
@property (nonatomic, retain) NSNumber * refreshInterval;
@property (nonatomic, retain) NSString * templateContent;
@property (nonatomic, retain) NSDictionary * dataContent;
@property (nonatomic, retain) NSDate * lastUpdateTime; //上一次更新数据的时间

#pragma mark - transient (view model)
// 模板是否已加载，未加载时cell高度返回0，避免出现空白cell的情况
@property (nonatomic, assign) BOOL hasTemplateLoaded;

// 模板未加载完成时，收到改变cell高度事件，只记录一下，模板加载结束后执行reload
@property (nonatomic, assign) BOOL shouldReloadCell;

//@property (nonatomic, retain) NSNumber *changedCellHeight;

- (void)updateWithTemplateContent:(NSString *)content templateMD5:(NSString *)md5 baseUrl:(NSString *)baseUrl;

- (void)updateWithDataContentObj:(NSDictionary *)content;

@end
