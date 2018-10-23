//
//  AWEVideoDetailManager.h
//  Pods
//
//  Created by 01 on 17/5/8.
//
//
#import <Foundation/Foundation.h>
#import "TSVShortVideoOriginalData.h"

typedef void(^AWEVideoDetailDataBlock)(TTShortVideoModel *model, NSError *error);
typedef void(^AWEVideoDetailCommonBlock)(id response, NSError *error);
typedef void(^AWEVideoDiggBlock)(BOOL succeed);
typedef void(^AWEVideoDislikeBlock)(id response);
typedef void(^AWEVideoFavoriteBlock)(id response);

@interface AWEVideoDetailManager : NSObject

+ (void)diggVideoItemWithID:(NSString *)groupID
                groupSource:(NSString *)groupSource
                 completion:(AWEVideoDiggBlock)block;

+ (void)cancelDiggVideoItemWithID:(NSString *)groupID
                       completion:(AWEVideoDiggBlock)block;

+ (void)startReportVideo:(NSString *)reportType
           userInputText:(NSString *)inputText
                 groupID:(NSString *)groupID
                 videoID:(NSString *)videoID
              completion:(AWEVideoDetailCommonBlock)block;
@end
