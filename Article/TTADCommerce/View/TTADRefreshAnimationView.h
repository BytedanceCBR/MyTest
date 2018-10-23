//
//  TTADRefreshAnimation.h
//  Pods
//
//  Created by ranny_90 on 2017/3/24.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTRefreshView.h"
#import "TTAdRefreshRelateModel.h"

@class TTADRefreshManager;

typedef void (^TTADRefreshAnimationViewBlock)(CGFloat animatePercent);

@interface TTADRefreshAnimationView : SSThemedView<TTRefreshAnimationDelegate>

@property (nonatomic,strong)NSString *channelId;

-(BOOL)configureAdImageData:(NSData *)adImageData;

@property (nonatomic,strong)TTAdRefreshItemModel *adItemModel;

-(id)initWithFrame:(CGRect)frame WithLoadingHeight:(CGFloat)loadingHeight WithLoadingText:(NSString *)loadingText;

@end
