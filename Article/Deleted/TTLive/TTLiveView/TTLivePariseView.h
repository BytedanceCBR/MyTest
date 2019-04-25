//
//  TTLivePariseView.h
//  Article
//
//  Created by 杨心雨 on 2016/10/23.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

/** 点赞透明背景 */
@interface TTLivePariseView : UIView

/** 起点横向偏移量 */
@property (nonatomic) CGFloat startOffsetX;

/** 用户点赞 */
- (void)userPariseWithUserImage:(NSString * _Nonnull)userImage commonImage:(NSString * _Nonnull)commonImage;
/** 他人点赞 */
- (void)otherPariseWithCommonImage:(NSString * _Nonnull)commonImage;

@end
