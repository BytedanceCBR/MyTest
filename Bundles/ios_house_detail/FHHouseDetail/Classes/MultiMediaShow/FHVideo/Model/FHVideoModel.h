//
//  FHVideoModel.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/16.
//

#import <Foundation/Foundation.h>
#import "AWEVideoPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHVideoModel : NSObject

@property(nonatomic, copy) NSString *contentUrl;
@property(nonatomic, assign) BOOL muted;
@property(nonatomic, assign) BOOL useCache;
@property(nonatomic, assign) BOOL repeated;
@property(nonatomic, assign) BOOL scalingMode;
@property(nonatomic, assign) AWEVideoScaleMode mode;
@property(nonatomic, assign) BOOL isShowMiniSlider;


@end

NS_ASSUME_NONNULL_END
