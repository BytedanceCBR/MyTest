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

@end

@interface FHUGCPostMenuView : UIView

@property (nonatomic, weak) id<FHUGCPostMenuViewDelegate> delegate;

- (void)show;
- (void)hide;
@end

NS_ASSUME_NONNULL_END
