//
//  FHUGCPostMenuView.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHUGCPostMenuViewDelegate <NSObject>

- (void)gotoPostPublish;
- (void)gotoVotePublish;

@optional

- (void)postMenuViewWillShow;
- (void)postMenuViewDidShow;
- (void)postMenuWillHide;
- (void)postMenuDidHide;

@end

@interface FHUGCPostMenuView : UIView

@property (nonatomic, weak) id<FHUGCPostMenuViewDelegate> delegate;

- (void)showForButton:(UIButton *)button;

@end

NS_ASSUME_NONNULL_END
