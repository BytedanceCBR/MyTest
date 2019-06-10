//
//  TTVPlayerLayoutBottomView.h
//  Article
//
//  Created by yangshaobo on 2018/11/2.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerKeyView.h"

@class TTVContainerSortView;

@interface TTVPlayerLayoutBottomView : TTVPlayerKeyView

@property (nonatomic, strong, readonly) TTVContainerSortView *noFullScreenRightContainerView;

@property (nonatomic, strong, readonly) TTVContainerSortView *fullScreenRightContainerView;

@property (nonatomic, strong, readonly) TTVContainerSortView *fullScreenLeftContainerView;

@property (nonatomic, assign) BOOL isFullScreen;
@end

