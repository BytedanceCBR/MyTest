//
//  FHShortVideoTracerUtil.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/9/25.
//

#import <Foundation/Foundation.h>
#import "FHFeedUGCCellModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHShortVideoTracerUtil : NSObject
+ (void)feedClientShowWithmodel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index;

+ (void)videoPlayOrPauseWithName:(NSString *)event eventModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index;

+ (void)videoOverWithModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index forStayTime:(NSString *)stayTime;

+ (void)goDetailWithModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index;

+ (void)stayPageWithModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index forStayTime:(NSString *)stayTime;

+ (void)clickLikeOrdisLikeWithWithName:(NSString *)event eventPosition:(NSString *)position eventModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index commentId:(NSString *)commentId;

+ (void)clickCommentWithModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index eventPosition:(NSString *)position;

+ (void)clickCommentSubmitWithModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index;

+ (void)clickshareBtn:(FHFeedUGCCellModel *)model;

+ (void)clicksharePlatForm:(FHFeedUGCCellModel *)model eventPlantFrom:(NSString *)platFrom;

+ (void)clickFavoriteBtn:(FHFeedUGCCellModel *)model favorite:(BOOL)isFavorite;

- (void)flushStayPageTime;
- (NSTimeInterval)timeIntervalForStayPage;

+ (NSString *)pageType ;
@end

NS_ASSUME_NONNULL_END
