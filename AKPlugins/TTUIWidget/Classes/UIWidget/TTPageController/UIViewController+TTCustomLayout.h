//
//  UIViewController+TTCustomLayout.h
//  Article
//
//  Created by Dai Dongpeng on 4/18/16.
//
//

@protocol TTLayoutProtocol;

@interface UIViewController (TTCustomLayout)

@property (nonatomic, strong) id <TTLayoutProtocol> tt_layout;

- (void)tt_resetLayoutToMinHeader:(BOOL)animated;
- (void)tt_resetLayoutToMaxHeader:(BOOL)animated;
- (void)tt_resetLayoutSubItems;

@end

@protocol TTLayoutProtocol <NSObject>
- (void)layoutWillAddToTargetViewController:(UIViewController *)targetViewController;
- (void)layoutDidAddToTargetViewController:(UIViewController *)targetViewController;
@optional
- (void)resetLayoutToMinHeader:(BOOL)animated;
- (void)resetLayoutToMaxHeader:(BOOL)animated;
- (void)resetLayoutSubItems;

@end
