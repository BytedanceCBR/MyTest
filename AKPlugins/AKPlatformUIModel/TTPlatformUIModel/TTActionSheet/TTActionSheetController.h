//
//  TTActionSheetController.h
//  Article
//
//  Created by zhaoqin on 9/1/16.
//
//

#import <Foundation/Foundation.h>
#import "TTActionSheetConst.h"

@interface TTActionSheetController : NSObject

@property (nonatomic, copy, nullable  ) NSString *itemID;
@property (nonatomic, copy, nullable  ) NSString *groupID;
@property (nonatomic, strong) NSString * _Nullable source;//埋点用
@property (nonatomic, assign) BOOL isSendTrack;//只有文章详情页dislike和report加埋点
@property (nonatomic, strong) NSDictionary * _Nullable extra;//只有详情页右上角更多埋点需要
@property (nonatomic, strong) void(^_Nullable trackBlock)();
@property (nonatomic, strong) NSNumber * _Nullable adID;

/**
 *  详情页dislike
 *
 *  @param dislikeArray dislike选项
 *  @param reportArray  举报选项
 */
- (void)insertDislikeArray:(NSArray * _Nullable)dislikeArray reportArray:(NSArray * _Nullable)reportArray;

/**
 *  其他举报
 *
 *  @param reportArray 举报选项
 */
- (void)insertReportArray:(NSArray * _Nullable)reportArray;

/**
 *  只有dislike选项
 *
 *  @param dislike选项
 */
- (void)insertDislikeArray:(NSArray * _Nullable)dislikeArray;

/**
 *  呈现TTActionSheet
 *
 *  @param source
 *  @param completion 
 */
- (void)performWithSource:(TTActionSheetSourceType)source completion:(nullable void (^)(NSDictionary *_Nonnull parameters))completion;

@end
