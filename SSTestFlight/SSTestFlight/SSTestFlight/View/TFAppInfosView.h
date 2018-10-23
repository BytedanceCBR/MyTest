//
//  TFAppInfosView.h
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-29.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFAppInfosModel.h"

@interface TFAppInfosView : UIView
@property(nonatomic, retain)UIButton * bgButton;
- (void)setAppInfosModel:(TFAppInfosModel *)model modelIndex:(NSUInteger)row;

+ (CGFloat)heightForCellWithModel:(TFAppInfosModel *)model cellWidth:(CGFloat)width;

@end
