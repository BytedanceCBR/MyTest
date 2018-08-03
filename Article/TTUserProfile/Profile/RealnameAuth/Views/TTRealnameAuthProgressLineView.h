//
//  TTRealnameAuthProgressLineView.h
//  Article
//
//  Created by lizhuoli on 16/12/18.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

@interface TTRealnameAuthProgressLineView : SSThemedView

/** 进度条百分比 */
@property (nonatomic, assign) CGFloat percent;
/** 剩余进度条颜色 */
@property (nonatomic, strong) UIColor *leftColor;
/** 已经处理进度条颜色 */
@property (nonatomic, strong) UIColor *processColor;

@end
