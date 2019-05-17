//
//  TTVPlayerLayoutTopView.h
//  Article
//
//  Created by yangshaobo on 2018/11/2.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerKeyView.h"

@class TTVContainerSortView;

@interface TTVPlayerLayoutTopView : TTVPlayerKeyView 

@property (nonatomic, strong, readonly) TTVContainerSortView *rightViewsContainerView;

@property (nonatomic, strong, readonly) TTVContainerSortView *leftViewsContainerView;

@property (nonatomic, strong, readonly) TTVContainerSortView *rightRectangleViewsContainerView;

@property (nonatomic, assign) BOOL isFullScreen;

@end
