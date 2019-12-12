//
// Created by zhulijun on 2019-12-10.
// Copyright (c) 2019 HeshamMegid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FHSegmentControl;

typedef void (^IndexChangeBlock)(NSInteger index);
@interface FHSegmentControl : UIControl
@property(nonatomic, strong) NSArray<NSString *> *sectionTitles;
@property(nonatomic, strong) NSDictionary *titleTextAttributes;
@property(nonatomic, strong) NSDictionary *selectedTitleTextAttributes;
@property(nonatomic, strong) UIColor *selectionIndicatorColor;
@property(nonatomic, assign) NSInteger selectedSegmentIndex;
@property(nonatomic, assign) CGSize selectionIndicatorSize;
@property (nonatomic, assign) CGFloat selectionIndicatorCornerRadius;
@property(nonatomic, getter = isTouchEnabled) BOOL touchEnabled;
@property (nonatomic) BOOL shouldAnimateUserSelection;
@property (nonatomic, copy) IndexChangeBlock indexChangeBlock;

- (id)initWithSectionTitles:(NSArray<NSString *> *)sectionTitles;

- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated;
@end
