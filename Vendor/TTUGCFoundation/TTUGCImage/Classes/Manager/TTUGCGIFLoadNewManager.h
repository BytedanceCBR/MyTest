//
//  TTUGCGIFLoadNewManager.h
//  TTUGCFoundation
//
//  Created by jinqiushi on 2018/10/18.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, TTUGCGifPriority) {
    TTUGCGifPriorityLow = 0,
    TTUGCGifPriorityNormal,
    TTUGCGifPriorityHigh,
};

@class FRImageInfoModel;

@interface TTUGCGIFLoadNewManager : NSObject

+ (instancetype)sharedInstance;

- (void)enterWorkingRangeForGifArray:(NSArray <FRImageInfoModel *> *)gifArray;

- (void)cellAppearForGifArray:(NSArray <FRImageInfoModel *> *)gifArray;

- (void)cellDisappearForGifArray:(NSArray <FRImageInfoModel *> *)gifArray;

- (void)imediatelyStartDownloadForGifModel:(FRImageInfoModel *)gifModel;

- (void)enhanceNextGifHighPriorityForGifModel:(FRImageInfoModel *)gifModel;

@end

@interface TTUGCGifDownloadModel : NSObject

@property (nonatomic, strong, readonly) FRImageInfoModel *gifInfoModel;
@property (nonatomic, assign) TTUGCGifPriority priority;
@property (nonatomic, copy) NSString *preGifKey;

- (instancetype)initWithGifInfoModel:(FRImageInfoModel *)gifInfoModel;

@end
