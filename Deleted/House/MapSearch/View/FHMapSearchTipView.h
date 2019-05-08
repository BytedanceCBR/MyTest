//
//  FHMapSearchTipView.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMapSearchTipView : UIView

-(void)showIn:(UIView *)view at:(CGPoint)topLeft content:(NSString *)content duration:(NSTimeInterval)duration above:(UIView *)aboveView;

-(void)removeTip;

@end

NS_ASSUME_NONNULL_END
