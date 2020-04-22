//
//  FHDetailPictureNavView.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 视频 图片
@interface FHDetailVideoTitle : UIView

@property (nonatomic, assign)   BOOL       isSelectVideo; // 是否选中视频
@property(nonatomic, copy) void (^currentTitleBlock)(NSInteger currentIndex);// 1是视频 2 是图片

@end

@interface FHDetailPictureNavView : UIView

@property(nonatomic , copy) void (^backActionBlock)();
@property(nonatomic , copy) void (^albumActionBlock)();

@property (nonatomic, strong)   UILabel       *titleLabel;// 图片
@property (nonatomic, assign)   BOOL       hasVideo;// 是否有视频
@property (nonatomic, strong)   FHDetailVideoTitle       *videoTitle;
@property (nonatomic, assign) BOOL showAlbum;// 是否有全部图片

@end

NS_ASSUME_NONNULL_END
