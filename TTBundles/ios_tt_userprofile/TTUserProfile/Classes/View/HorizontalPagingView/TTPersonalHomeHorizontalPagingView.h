//
//  TTPersonalHomeHorizontalPagingView.h
//  Article
//
//  Created by wangdi on 2017/3/18.
//
//

#import "TTHorizontalPagingView.h"

@interface TTPersonalHomeHorizontalPagingView : TTHorizontalPagingView

- (void)reloadHeaderViewHeight:(CGFloat)height;
@property (nonatomic, assign) BOOL isAnimation;

@end
