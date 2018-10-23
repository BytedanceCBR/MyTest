//
//  TTImagePreviewPhotoView.h
//  Article
//
//  Created by SongChai on 2017/4/10.
//
//

#import <UIKit/UIKit.h>
#import "TTAssetModel.h"
#import "FLAnimatedImageView.h"

@class TTImagePreviewViewController;

@interface TTImagePreviewPhotoView : UIView<UIScrollViewDelegate>
@property (nonatomic, strong) FLAnimatedImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *imageContainerView;

@property (nonatomic, strong) TTAssetModel *model;
//@property (nonatomic, strong) id asset;
@property (nonatomic, copy) void (^singleTapGestureBlock)();
@property (nonatomic, weak) TTImagePreviewViewController *myVC;

- (void)photoViewDidDisplay;
- (void)recoverSubviews;
@end
