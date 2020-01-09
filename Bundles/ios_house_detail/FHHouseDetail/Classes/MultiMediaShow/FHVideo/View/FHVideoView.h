//
//  FHVideoView.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/12.
//

#import <UIKit/UIKit.h>
#import "FHVideoModel.h"
#import "FHVideoCoverView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FHVideoViewDelegate <NSObject>

- (void)startPlayVideo;

@end

@interface FHVideoView : UIView

@property(nonatomic , weak) id<FHVideoViewDelegate> delegate;
@property(nonatomic, strong) FHVideoCoverView *coverView;
@property(nonatomic ,strong) UIView *playerView;


- (instancetype)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
