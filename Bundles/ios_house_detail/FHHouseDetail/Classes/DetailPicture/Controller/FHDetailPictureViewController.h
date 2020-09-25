//
//  FHDetailPictureViewController.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/15.
//
//改造成数据驱使！！！！！！！！！！！！！！！！！！！！！！
#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "TTPhotoScrollViewController.h"
#import "FHDetailMediaHeaderCell.h"
#import "FHVideoViewController.h"
#import "FHDetailPictureModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHClueAssociateInfoModel;

// 支持房源图片以及视频相关功能
@interface FHDetailPictureViewController : FHBaseViewController

/** 图片数据 */
//创建一个新的数据结构
@property (nonatomic, strong) FHDetailPictureModel *detailPictureModel;

//线索数据
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;

//大图图片线索
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *imageGroupAssociateInfo;
//VR线索
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *vrImageAssociateInfo;
//视频线索
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *videoImageAssociateInfo;


@property (nonatomic, weak)     UIViewController       *topVC;
@property(nonatomic, strong) UIScrollView * photoScrollView;
/** 当前index */
@property(nonatomic, assign, readonly)NSInteger currentIndex;
/** 打开的时候需要展示的index */
@property(nonatomic, assign)NSUInteger startWithIndex;
/**如果外面传了视频控制器就用外面的，如果没有就自己生成一个，但是退出该控制器后视频进度不会保存*/
@property (nonatomic, weak)     FHVideoViewController      *videoVC;

/** 图片个数 */
@property(nonatomic, assign, readonly)NSInteger photoCount;

/**点击图片 */
@property(nonatomic, copy) void (^clickImageBlock)(NSInteger currentIndex);

/** 滚动引起index改变的时候调用 */
@property(nonatomic, copy) void (^indexUpdatedBlock)(NSInteger lastIndex, NSInteger currentIndex);
/** 图片保存的时候调用 */
@property(nonatomic, copy) void (^saveImageBlock)(NSInteger currentIndex);

/**点击全部图片*/
@property(nonatomic, copy) void (^albumImageBtnClickBlock)(NSInteger index);

/**点击头图的tab栏出现的埋点*/
@property(nonatomic, copy) void (^clickTitleTabBlock)(NSInteger index);


/** 详情页数据 */
@property (nonatomic, copy)     NSString       *houseId;
@property (nonatomic, assign)     FHHouseType       houseType;

@property (nonatomic, copy)     NSString       *priceStr;
@property (nonatomic, copy)     NSString       *infoStr;

@property (nonatomic, assign)   NSInteger       followStatus;// 收藏状态

@property(nonatomic , copy) void (^shareActionBlock)(void);
@property(nonatomic , copy) void (^collectActionBlock)(BOOL followStatus);

/** 图片URL数组*/
@property(nonatomic, strong)NSArray * imageURLs; //every item also is array, and it contains url and header infos

/** TTImageInfosModel数组*/
@property(nonatomic, strong, nullable) NSArray *imageInfosModels;

/** Extended by luohuaqing to support selecting image on preview */
//@property (nonatomic, assign)PhotosScrollViewMode mode;
@property (nonatomic, strong, nullable) NSArray *images;
@property (nonatomic, strong, nullable) NSArray *assetsImages;

/** 是否支持长按保存，默认YES */
@property (nonatomic, assign)BOOL longPressToSave;

/** 是否显示底部bottombar以及按钮，默认YES */
@property (nonatomic, assign)BOOL isShowBottomBar;

/// 头部切换name类型的view是否显示，默认YES
@property (nonatomic, assign) BOOL isShowSegmentView;

//099户型详情 查看大图新增 title & 售卖 状态字段
@property (nonatomic, copy) NSString *bottomBarTitle;

// Extended by lizhuoli to support drag down and drag up to close

/** 是否禁止上拉和下拉关闭，默认NO */
@property (nonatomic, assign)BOOL dragToCloseDisabled;
/** 关闭时候图片移出动画的忽略遮罩Insets */
@property (nonatomic, assign)UIEdgeInsets dismissMaskInsets;


/** Extended by xuzichao to support multiple type of image,including  url,assets,image,imageinfomodel,NSUrl 相册资源路径 */
@property (nonatomic, strong, nullable) NSArray *multipleTypeImages;

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


@end

NS_ASSUME_NONNULL_END
