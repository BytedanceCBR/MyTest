//
//  TTHorizontalHuoShanCollectionCellProtocol.h
//  Article
//
//  Created by 邱鑫玥 on 2017/7/20.
//

#import <UIKit/UIKit.h>
#import "TTShortVideoHelper.h"

@class ExploreOrderedData;

@protocol TTHorizontalHuoShanCollectionCellProtocol<NSObject>

+ (CGFloat)heightForHuoShanVideoWithCellWidth:(CGFloat)width;

- (void)setupDataSourceWithData:(ExploreOrderedData *)orderedData;

- (CGRect)coverImageViewFrame;

@end
