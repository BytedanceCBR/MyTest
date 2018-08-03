//
//  TTActionSheetTextController.h
//  Article
//
//  Created by zhaoqin on 8/30/16.
//
//

#import <UIKit/UIKit.h>
#import "TTActionSheetConst.h"

@class TTActionSheetManager;

@interface TTActionSheetTextController : UIViewController
@property (nonatomic, assign) TTActionSheetSourceType source;
@property (nonatomic, assign) CGFloat viewHeight;//当前页面的高度，在TTActionSheetAnimated中执行动画用到
@property (nonatomic, strong) TTActionSheetManager *manager;

@end
