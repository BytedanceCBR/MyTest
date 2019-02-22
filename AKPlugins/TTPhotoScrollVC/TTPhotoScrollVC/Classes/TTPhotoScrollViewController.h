//
//  TTPhotoScrollViewController.h
//  Article
//
//  Created by Zhang Leonardo on 12-12-4.
//  Edited by Cao Hua from 13-10-12.
//

#import <UIKit/UIKit.h>
#import "TTImageInfosModel.h"

typedef void(^TTPhotoScrollViewDismissBlock) ();

typedef enum : NSUInteger {
    PhotosScrollViewSupportDownloadMode = 0, // default value
    PhotosScrollViewSupportSelectMode = 1,
    PhotosScrollViewSupportBrowse = 2 , //仅仅浏览
} PhotosScrollViewMode;

typedef NS_ENUM(NSInteger, TTPhotoScrollViewMoveDirection) {
    TTPhotoScrollViewMoveDirectionNone, //未知
    TTPhotoScrollViewMoveDirectionVerticalTop, //向上
    TTPhotoScrollViewMoveDirectionVerticalBottom //向下
};

@protocol TTPhotoScrollViewControllerDelegate;

@interface TTPhotoScrollViewController : UIViewController

/** 当前index */
@property(nonatomic, assign, readonly)NSInteger currentIndex;
/** 打开的时候需要展示的index */
@property(nonatomic, assign)NSUInteger startWithIndex;
/** 图片个数 */
@property(nonatomic, assign, readonly)NSInteger photoCount;
/** 滚动引起index改变的时候调用 */
@property(nonatomic, copy) void (^indexUpdatedBlock)(NSInteger lastIndex, NSInteger currentIndex);
/** 图片保存的时候调用 */
@property(nonatomic, copy) void (^saveImageBlock)(NSInteger currentIndex);

/** 图片URL数组*/
@property(nonatomic, strong)NSArray * imageURLs; //every item also is array, and it contains url and header infos

/** 图片title数组*/
@property(nonatomic, strong)NSArray * imageTitles;

/** TTImageInfosModel数组*/
@property(nonatomic, strong)NSArray * imageInfosModels;

/** Extended by luohuaqing to support selecting image on preview */
@property (nonatomic, assign)PhotosScrollViewMode mode;
@property (nonatomic, strong)NSArray * images;
@property (nonatomic, strong)NSArray * assetsImages;
@property (nonatomic, strong)NSMutableArray * isSelecteds;
@property (nonatomic, assign)NSUInteger selectLimit;
@property (nonatomic, assign)BOOL autoSelectImageWhenClickDone;

/** 是否支持长按保存，默认YES */
@property (nonatomic, assign)BOOL longPressToSave;

// Extended by lizhuoli to support drag down and drag up to close

/** 是否禁止上拉和下拉关闭，默认NO */
@property (nonatomic, assign)BOOL dragToCloseDisabled;
/** 关闭时候图片移出动画的忽略遮罩Insets */
@property (nonatomic, assign)UIEdgeInsets dismissMaskInsets;


/** Extended by xuzichao to support multiple type of image,including  url,assets,image,imageinfomodel,NSUrl 相册资源路径 */
@property (nonatomic, strong)NSArray * multipleTypeImages;

/** UIImage(s); Optional ([NSNull null] is used to represent the absence) */
@property (nonatomic, strong)NSArray * placeholders;

/** Frame(s) based on window coordinate; Optional */
@property (nonatomic, strong)NSArray * placeholderSourceViewFrames;

@property (nonatomic, copy)NSString * umengEventName;
@property (nonatomic, weak)id<TTPhotoScrollViewControllerDelegate> delegate;


/** targetView 用于手势拖动提供一个放白布遮罩的view 使用前可以借鉴一下其他地方的用法*/
@property (nonatomic, weak)UIView *targetView;
/** finishBackView 用于手势拖动提供一个结束动画所在的view */
@property (nonatomic, weak)UIView *finishBackView;
/**     whiteMaskViewEnable 是否需要白色遮罩 */
@property (nonatomic, assign)BOOL whiteMaskViewEnable;

/** 将VC展示出来 */
- (void)presentPhotoScrollView;
/** 将VC展示出来 并提供一个回调*/
- (void)presentPhotoScrollViewWithDismissBlock:(TTPhotoScrollViewDismissBlock)block;
- (void)dismissSelf;
/**
 是否正在展示图片选择器
 @return YES / NO
 */
+ (BOOL)photoBrowserAtTop;


/**
 extend by xuzichao to support SSTracker
 只有一些埋点用了trackerDic
 @param trackerDic 发埋点用
 @return instancetype
 */
- (instancetype)initWithTrackDictionary:(NSDictionary *)trackerDic;

@end

@protocol TTPhotoScrollViewControllerDelegate <NSObject>

@optional


/**
 点击完成后的回调

 @param sender 当前的图片选择器
 */
- (void)TTPhotoScrollViewControllerDidFinishSelect:(TTPhotoScrollViewController *)sender;

/**
 图片选择器在结束滑动的回调

 @param controller 当前的图片选择器
 @param index 对应图片的索引
 */
- (void)photoScrollViewController:(TTPhotoScrollViewController *)controller didScrollToIndex:(NSInteger)index;

@end
