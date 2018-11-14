//
//  FHErrorMaskView.h
//  Article
//
//  Created by 谷春晖 on 2018/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHErrorMaskView : UIView

@property(nonatomic , copy) void (^retryBlock)();

-(void)showError:(NSError *)error;

-(void)showErrorWithTip:(NSString *)tip;

@end

NS_ASSUME_NONNULL_END
