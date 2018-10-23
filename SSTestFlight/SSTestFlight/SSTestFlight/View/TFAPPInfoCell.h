//
//  TFAPPInfoCell.h
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-28.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFAppInfosModel.h"

@protocol TFAPPInfoCellDelegate;

@interface TFAPPInfoCell : UITableViewCell

@property(nonatomic, assign)id<TFAPPInfoCellDelegate> delegate;

- (void)setAppInfosModel:(TFAppInfosModel *)model modelIndex:(NSUInteger)row;

+ (CGFloat)heightForCellWithModel:(TFAppInfosModel *)model cellWidth:(CGFloat)width;

@end

@protocol TFAPPInfoCellDelegate <NSObject>

@optional

- (void)tableViewCellDidSelectedBackgroundButton:(TFAPPInfoCell *)cell selectedModel:(TFAppInfosModel *)model selectedIndex:(NSUInteger)index;

@end