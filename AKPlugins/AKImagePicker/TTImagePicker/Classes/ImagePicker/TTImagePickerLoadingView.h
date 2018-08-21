//
//  TTImagePickerLoadingView.h
//  LoadingIcon
//
//  Created by tyh on 2017/7/5.
//  Copyright © 2017年 tyh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RetryBlock)(void);

@interface TTImagePickerLoadingView : UIView

///加载进度,0~1
@property(nonatomic,assign)float progress;
///边框颜色
@property(nonatomic,strong)UIColor *borderColor;
///填充颜色
@property(nonatomic,strong)UIColor *fillColor;
///边框宽度
@property(nonatomic,assign)CGFloat borderWidth;
///内填充
@property(nonatomic,assign)CGFloat inset;
///自动消失，当progress为1
@property(nonatomic,assign)BOOL autoDismissWhenCompleted;
///失败的视图
@property(nonatomic,assign)BOOL isFailed;
///是否需要重试文案
@property(nonatomic,assign)BOOL isShowFailedLabel;
///重试Action
@property(nonatomic,copy)RetryBlock retry;

///移除views
- (void)removeViews;



@end
