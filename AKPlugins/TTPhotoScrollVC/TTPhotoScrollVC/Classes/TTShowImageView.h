//
//  TTShowImageView.h
//  Article
//
//  Created by Zhang Leonardo on 12-11-12.
//  Edited by Cao Hua from 13-10-12.
//

#import <UIKit/UIKit.h>

#import "SSViewBase.h"
#import "TTImageInfosModel.h"
#import "ALAssetsLibrary+TTAddition.h"
@class TTUIShortTapGestureRecognizer;

typedef void(^LoadingImageCompletedAnimationBlock)(void);

@protocol TTShowImageViewDelegate;

@interface TTShowImageView : SSViewBase

/** 对应原图的URL */
@property(nonatomic, strong)NSString * largeImageURLString;
/** 图片的Model */
@property(nonatomic, strong)TTImageInfosModel * imageInfosModel;
/** delegate，可以获得单击和双击的回调 */
@property(nonatomic, weak)id<TTShowImageViewDelegate>delegate;
/** 如果不循环的话，播放结束停在最后一帧 */
@property(nonatomic, assign)BOOL gifRepeatIfHave;


/** 拿到图片的元信息 */
@property(nonatomic, strong)UIImage * image;
@property(nonatomic, strong)UIImage * imageData;
@property(nonatomic, strong)ALAsset * asset;

@property(nonatomic, assign, getter=isVisible)BOOL visible;

@property(nonatomic, strong)UIImage * placeholderImage;
@property(nonatomic, assign)CGRect placeholderSourceViewFrame;
@property(nonatomic, strong)TTUIShortTapGestureRecognizer * tapGestureRecognizer;

// For show up animation
@property(nonatomic, assign, readonly)BOOL isDownloading;
@property(nonatomic, copy)LoadingImageCompletedAnimationBlock loadingCompletedAnimationBlock;


/**
 将scrollView的Zoom设置成1
 */
- (void)resetZoom;

/**
 更新UI，如果处于缩放的话，会还原会正常状态
 */
- (void)refreshUI;

/**
 重头播放gif
 */
- (void)restartGifIfNeeded;

/**
 如果有Gif马上播放
 */
- (void)showGifIfNeeded;

/**
 停止播放gif
 */
- (void)hideGifIfNeeded;

/**
 保存图片，会弹出alert进行询问
 */
- (void)saveImage;
/**
 将saveImageAlertView置为nil
 */
- (void)destructSaveImageAlert;


/**
 displayImageView

 @return 得到当前的imageView
 */
- (UIImageView *)displayImageView;

/**
 displayImageView和currentImageView的区别是后者可以获得gif的view

 @return 得到当前的imageView
 */
- (UIImageView *)currentImageView;

/**
 currentImageViewFrame

 @return 得到当前imageView的frame
 */
- (CGRect)currentImageViewFrame;

@end

@protocol TTShowImageViewDelegate<NSObject>

@optional

/**
 单次点击的回调

 @param imageView 当前正在展示的imageView
 */
- (void)showImageViewOnceTap:(TTShowImageView *)imageView;

/**
 双击的回调

 @param imageView 当前正在展示的imageView
 */
- (void)showImageViewDoubleTap:(TTShowImageView *)imageView;

@end
