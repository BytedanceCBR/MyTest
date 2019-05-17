//
//  ExploreVideoDetailHelper.h
//  Article
//
//  Created by 冯靖君 on 15/11/15.
//
//

#import <Foundation/Foundation.h>

/*
 *  ipad相关视频展示样式，根据屏幕宽度进行适配
 */
typedef NS_ENUM(NSInteger, VideoDetailRelatedStyle)
{
    VideoDetailRelatedStyleNatant,   //浮层中展示
    VideoDetailRelatedStyleDistinct  //独立展示
};

@interface ExploreVideoDetailHelper : NSObject

/*
 *  根据window宽度决定视频详情页的样式(ipad有分屏情况)
 */
+ (VideoDetailRelatedStyle)currentVideoDetailRelatedStyle;
+ (VideoDetailRelatedStyle)currentVideoDetailRelatedStyleForMaxWidth:(CGFloat)maxWidth;
+ (CGSize)videoAreaSizeForMaxWidth:(CGFloat)maxWidth areaAspect:(CGFloat)areaAspect;//areaAspect 高:宽

@end
