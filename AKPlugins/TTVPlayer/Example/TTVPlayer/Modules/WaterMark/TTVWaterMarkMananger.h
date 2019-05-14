//
//  TTVWaterMarkMananger.h
//  Article
//
//  Created by panxiang on 2018/7/23.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStore.h"
#import "TTVPlayer.h"

@interface TTVWaterMarkMananger : NSObject<TTVPlayerContext>
/**
 @param image small screen logo
 @param fullImage full screen logo
 */
- (void)setWatermarkImage:(UIImage *)image watermarkFullImage:(UIImage *)fullImage;
- (void)defaultWaterMark;
@end

@interface TTVPlayer (WaterMark)
- (TTVWaterMarkMananger *)waterMarkMananger;
@end
