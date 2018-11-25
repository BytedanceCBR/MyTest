//
//  FHHomeTrendBubbleView.h
//  Article
//
//  Created by 张静 on 2018/11/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FHHomeTrendBubbleViewActionBlock)(void);

@interface FHHomeTrendBubbleView : UIView

-(void)updateTitle:(NSString *)title;

-(void)showFromView:(UIView *)view withDissmissAction:(FHHomeTrendBubbleViewActionBlock)actionBlock;
-(void)dismiss;

@end

NS_ASSUME_NONNULL_END
