//
//  FHFeedCustomHeaderView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/30.
//

#import <UIKit/UIKit.h>
#import "FHPostUGCProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFeedCustomHeaderView : UIView

@property (nonatomic, weak) FHPostUGCProgressView *progressView;

- (instancetype)initWithFrame:(CGRect)frame addProgressView:(BOOL)addProgressView;

@end

NS_ASSUME_NONNULL_END
