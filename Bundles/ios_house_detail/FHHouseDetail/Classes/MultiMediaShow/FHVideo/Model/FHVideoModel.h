//
//  FHVideoModel.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/16.
//

#import <Foundation/Foundation.h>
#import "TTVideoEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHVideoModel : NSObject

@property(nonatomic, copy) NSString *contentUrl;
@property(nonatomic, copy) NSString *coverImageUrl;
@property(nonatomic, copy) NSString *videoID;
@property(nonatomic, assign) CGFloat vWidth;
@property(nonatomic, assign) CGFloat vHeight;
@property(nonatomic, assign) BOOL muted;
@property(nonatomic, assign) BOOL repeated;
@property(nonatomic, assign) BOOL isShowMiniSlider;
@property(nonatomic, assign) BOOL isShowControl;
//和isShowControld互斥
@property(nonatomic, assign) BOOL isShowStartBtnWhenPause;

@end

NS_ASSUME_NONNULL_END
