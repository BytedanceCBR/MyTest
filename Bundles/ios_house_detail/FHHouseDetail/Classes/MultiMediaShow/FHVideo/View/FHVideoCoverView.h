//
//  FHVideoCoverView.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHVideoCoverViewDelegate <NSObject>

- (void)playVideo;

@end

@interface FHVideoCoverView : UIView

@property(nonatomic, strong) UIImageView *coverView;
@property(nonatomic, strong) UIButton *startBtn;
@property(nonatomic, copy) NSString *imageUrl;
@property(nonatomic , weak) id<FHVideoCoverViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
