//
//  TTUGCPageControl.h
//  Article
//
//  Created by JvanChow on 19/12/2017.
//

#import "SSThemed.h"

@interface TTUGCPageControl : SSThemedView

- (instancetype)initWithNumberOfPages:(NSUInteger)numberOfPages currentPage:(NSUInteger)currentPage;
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;
@property (nonatomic, strong) UIColor *pageIndicatorTintColor;
@property (nonatomic, assign, readonly) NSUInteger numberOfPages;
@property (nonatomic, assign) NSUInteger currentPage;

@end
