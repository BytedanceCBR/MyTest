//
//  TTLayoutLoopPicCell.h
//  Article
//
//  Created by 曹清然 on 2017/6/20.
//
//

#import "ExploreCellBase.h"
#import "TTLayOutCellViewBase.h"

@interface TTLayoutLoopPicCell : ExploreCellBase

@end

@interface  TTLayoutLoopPicCellView: TTLayOutCellViewBase

-(void)willDisplay;

- (void)didEndDisplaying;

@end
