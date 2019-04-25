//
//  TTAdShareBoardView.h
//  Article
//
//  Created by yin on 2016/11/14.
//
//

#import "SSThemed.h"
#import "TTAdShareBoardModel.h"

//只针对320小屏幕做适配,大屏幕都按照固定高度做
#define kTTAdShareScreenRate (([UIScreen mainScreen].bounds.size.width == 320)? 0.9:1)

@interface TTAdShareBoardView : SSThemedView

- (instancetype)initWithFrame:(CGRect)frame model:(TTAdShareBoardDataModel*)model;

@end
