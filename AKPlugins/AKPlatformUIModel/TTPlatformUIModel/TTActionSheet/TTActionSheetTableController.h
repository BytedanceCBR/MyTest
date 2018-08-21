//
//  TTActionSheetTableController.h
//  Article
//
//  Created by zhaoqin on 8/27/16.
//
//

#import <UIKit/UIKit.h>
#import "TTActionSheetConst.h"

@class TTActionSheetModel;
@class TTActionSheetManager;

@interface TTActionSheetTableController : UIViewController
@property (nonatomic, strong) TTActionSheetModel *model;
@property (nonatomic, assign) CGFloat viewHeight;//当前页面的高度，在TTActionSheetAnimated中执行动画用到
@property (nonatomic, assign) TTActionSheetSourceType source;
@property (nonatomic, strong) TTActionSheetManager *manager;
@property (nonatomic, strong) void(^trackBlock)();
@property (nonatomic, strong) NSNumber *adID;
@end
