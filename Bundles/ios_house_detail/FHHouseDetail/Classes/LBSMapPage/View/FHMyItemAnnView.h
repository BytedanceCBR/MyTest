//
//  FHMyItemAnnView.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/7/30.
//

#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapCommonObj.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMyItemAnnView : MAAnnotationView

@property (nonnull, strong) AMapPOI * poi;
@property (nonnull, strong) UIView *backColorView;
@property (nonnull, strong) UIImageView *bottomArrowView;

@end

NS_ASSUME_NONNULL_END
