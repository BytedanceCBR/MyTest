//
//  FHDetailQuestionButton.h
//  FHBAccount
//
//  Created by 张静 on 2019/10/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailQuestionInternalButton: UIButton

@property (nonatomic, strong) UIImage *foldImage;
@property (nonatomic, strong) UIImage *unfoldImage;
@property (nonatomic, assign) BOOL isFold;

@end

@interface FHDetailQuestionButton : UIView

@property (nonatomic, strong) FHDetailQuestionInternalButton *btn;
@property (nonatomic, assign) BOOL isFold;
- (void)updateTitle:(NSString *)title;
- (CGFloat)totalWidth;

@end

NS_ASSUME_NONNULL_END
