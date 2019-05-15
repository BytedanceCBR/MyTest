//
//  TTVCommodityItemViewFull.h
//  Article
//
//  Created by panxiang on 2017/8/8.
//
//

#import <UIKit/UIKit.h>
@class TTVCommodityEntity;
@protocol TTVCommodityItemViewFullDelegate <NSObject>

- (void)ttv_didOpenCommodity:(TTVCommodityEntity *)entity isClickButton:(BOOL)isClickButton;

@end

@interface TTVCommodityItemViewFull : UIView
@property (nonatomic ,strong)TTVCommodityEntity *entity;
@property (nonatomic ,assign)BOOL isFullScreen;
@property (nonatomic ,weak)NSObject <TTVCommodityItemViewFullDelegate> *delegate;
@end

