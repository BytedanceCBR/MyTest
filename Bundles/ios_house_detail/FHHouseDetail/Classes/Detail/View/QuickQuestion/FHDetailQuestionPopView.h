//
//  FHDetailQuestionPopView.h
//  FHBAccount
//
//  Created by 张静 on 2019/10/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailQuestionPopMenuItem : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) id model;
@property(nonatomic, assign) NSInteger index;
@property(nonatomic, copy) void(^itemClickBlock)(FHDetailQuestionPopMenuItem *menuItem);


@end

@interface FHDetailQuestionPopView : UIView

@property(nonatomic, copy) void(^completionBlock)(void);
@property(nonatomic, strong) NSArray<FHDetailQuestionPopMenuItem *> *menus;

- (void)showAtPoint:(CGPoint)p parentView:(UIView *)parentView;
- (void)updateTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
