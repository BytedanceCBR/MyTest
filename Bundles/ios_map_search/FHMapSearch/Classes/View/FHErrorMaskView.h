//
//  FHErrorMaskView.h
//  Article
//
//  Created by 谷春晖 on 2018/11/14.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM( NSInteger , FHErrorMaskType){
    FHErrorMaskTypeNoNetwork = 0,
    FHErrorMaskTypeNoNews = 1,
    FHErrorMaskTypeNoData = 2,
    FHErrorMaskTypeNoAttention = 3,
} ;

NS_ASSUME_NONNULL_BEGIN

@interface FHErrorMaskView : UIView

@property(nonatomic , copy) void (^retryBlock)();

-(void)showError:(NSError *)error;

-(void)showErrorWithTip:(NSString *)tip;

-(void)showRetry:(BOOL)show;

-(void)enableTap:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
