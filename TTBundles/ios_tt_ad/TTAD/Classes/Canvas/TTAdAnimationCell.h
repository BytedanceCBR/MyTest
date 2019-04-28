//
//  TTAdAnimationCell.h
//  Article
//
//  Created by carl on 2017/5/19.
//
//

#import "ExploreArticleTitleLargePicCell.h"
#import "ExploreArticleTitleRightPicCell.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTLayOutLargePicCell.h"
#import "TTLayOutNewLargePicCell.h"
#import "TTLayOutRightPicCell.h"
#import "TTLayoutPanoramaViewCell.h"
#import "TTLayoutPanorama3DViewCell.h"
#import <Foundation/Foundation.h>

@protocol TTAdAnimationCell

/*！
 @abstract Feed Cell支持动画打开， 提供动画打开的参数
 @param orderData 当前Cell的数据模型
 @return 动画需要的上下文参数
 */
- (NSDictionary *)animationContextInfo:(ExploreOrderedData *)orderData;
@end

@interface TTLayOutRightPicCell (TTAdAnimationCell) <TTAdAnimationCell>
@end

@interface ExploreArticleTitleRightPicCell (TTAdAnimationCell) <TTAdAnimationCell>
@end

@interface TTLayOutLargePicCell (TTAdAnimationCell) <TTAdAnimationCell>
@end

@interface TTLayOutNewLargePicCell (TTAdAnimationCell) <TTAdAnimationCell>
@end

@interface ExploreArticleTitleLargePicCell (TTAdAnimationCell) <TTAdAnimationCell>
@end

@interface TTLayoutPanoramaViewCell (TTAdAnimationCell) <TTAdAnimationCell>
@end

@interface TTLayoutPanorama3DViewCell (TTAdAnimationCell) <TTAdAnimationCell>
@end

 // 组图直接走系统Push动画
 // TTLayOutGroupPicCell (TTAdAnimationCell) <TTAdAnimationCell>
 // ExploreArticleTitleGroupPicCell (TTAdAnimationCell) <TTAdAnimationCell>


