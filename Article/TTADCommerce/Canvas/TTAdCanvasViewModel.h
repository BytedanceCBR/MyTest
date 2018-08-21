//
//  TTAdCanvasViewModel.h
//  Article
//
//  Created by carl on 2017/7/16.
//
//

#import <Foundation/Foundation.h>
#import "TTAdCanvasModel.h"
#import "TTAdCanvasDefine.h"
#import "TTImageInfosModel.h"

@interface TTAdCanvasViewModel : NSObject

@property (nonatomic, copy) NSDictionary *layoutInfo; // 布局信息
@property (nonatomic, copy) NSDictionary *adInfo; //广告附加信息
@property (nonatomic, copy) NSDictionary *createFeedData; //创意联动信息
@property (nonatomic, assign) BOOL hasCreateFeedData;

@property (nonatomic, assign) TTAdCanvasOpenAnimation animationStyle;
@property (nonatomic, strong) TTImageInfosModel *canvasImageModel;
@property (nonatomic, strong) TTImageInfosModel *sourceImageModel;
@property (nonatomic, assign) CGRect soureImageFrame;

@property (nonatomic, assign) TTAdCanvasOpenStrategy openStrategy;

@property (nonatomic, strong) UIColor *rootViewColor;
@property (nonatomic, copy) NSString *log_extra;
@property (nonatomic, copy) NSString *ad_id;
@property (nonatomic, copy) NSString *fromSource;
@property (nonatomic, assign) BOOL share_enable;


- (instancetype)initWithCondition:(NSDictionary *)condition;
- (instancetype)initWithModel:(TTAdCanvasProjectModel *)projectModel;

@end
