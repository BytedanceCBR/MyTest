//
//  TTImageCollectionView.h
//  Article
//
//  Created by SunJiangting on 15/7/23.
//
//

#import <UIKit/UIKit.h>
//#import "STDefines.h"
#import "ExploreImageSubjectModel.h"
#import "TTShowImageView.h"
#import "SSThemed.h"
#import "TTPhotoDetailAdCollectionCell.h"
#import "TTPhotoDetailCellProtocol.h"

@class Article;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TTPhotoDetailImagePositon) {
    TTPhotoDetailImagePositon_NormalImage,
    TTPhotoDetailImagePositon_Ad,
    TTPhotoDetailImagePositon_Recom
};

@interface ExploreImageCollectionViewCell : UICollectionViewCell <TTPhotoDetailCellProtocol>


@property(nonatomic, strong) UIView          *blackShadowView;
@property(nonatomic, strong, readonly) TTShowImageView *imageScrollView;

@property(nonatomic) BOOL natantVisible;

@property(nonatomic, strong, readonly) SSThemedLabel     *titleLabel;
@property(nonatomic, strong, readonly) SSThemedLabel     *sequenceLabel;
@property(nonatomic, strong, readonly) SSThemedTextView  *abstractView;

@property(nonatomic) UIEdgeInsets   contentInset;

@property(nullable, nonatomic, strong) ExploreImageSubjectModel *subjectModel;


- (void)refreshBlackOpaqueWithPersent:(CGFloat)persent;
- (void)refreshRightDistanceWithPersent:(CGFloat)persent;

@end

@interface TTImageRecommendCell : UICollectionViewCell <UICollectionViewDataSource, UICollectionViewDelegate,TTPhotoDetailCellProtocol>

@property (nonatomic,weak) id<UIScrollViewDelegate> scrollDelegate;

@property (nonatomic) CGFloat contentTopInset;
/**
 *  相关图集所属源文章，ExploreImageCollectionView传入
 */
@property (nonatomic, strong) Article *sourceArticle;
- (void)setupImageInfo:(NSArray *)imageInfoArray;
/**
 * 相关图集搜索词
 */
- (void)setupSearchWordsArray:(NSArray *)searchWordsArray;
- (void)setupImageInfo:(NSArray *)imageInfoArray andSearchWords:(NSArray *)searchWordsArray;

/// impression
- (void)impressionStart4ImageRecommend;
- (void)impressionEnd4ImageRecommend;
@end

@class ExploreImageCollectionView;
@protocol ExploreImageCollectionViewDelegate <NSObject>

@optional
- (void)imageCollectionView:(nonnull ExploreImageCollectionView *)collectionView
     didChangeNatantVisible:(BOOL)newNatantVisible;
- (void)imageCollectionView:(nonnull ExploreImageCollectionView *)collectionView didScrollToIndex:(NSInteger)index;

- (void)imageCollectionView:(nonnull ExploreImageCollectionView *)collectionView didScrollTextView:(nonnull UITextView *)textView;

- (void)imageCollectionView:(nonnull ExploreImageCollectionView *)collectionView imagePositionType:(TTPhotoDetailImagePositon)imagePositionType tapOn:(BOOL)tapOn;

//- (void)imageCollectionView:(STNONNULL ExploreImageCollectionView *)collectionView didScrollInToImageRecommendCell:(BOOL)showRecommend;

- (void)imageCollectionView:(nonnull ExploreImageCollectionView *)collectionView didScrollImagePositionType:(TTPhotoDetailImagePositon)ImagePositionType;

- (void)imageCollectionView:(nonnull ExploreImageCollectionView *)collectionView scrollPercent:(CGFloat)scrollPercent;

- (void)imageCollectionView:(nonnull ExploreImageCollectionView *)collectionView didScrollToIndex:(NSInteger)index isLastPic:(BOOL)isLastPic;

@end
@interface ExploreImageCollectionView : UIView
/**
 *  相关图集所属源文章，外部传入
 */

@property(nullable, nonatomic, strong) SSThemedView      *natantView;
@property(nullable, nonatomic, strong) SSThemedTextView  *abstractView;
@property(nullable, nonatomic, strong) UIView* nextView;
@property(nullable, nonatomic, strong) Article *sourceArticle;
@property(nullable, nonatomic, weak) id<ExploreImageCollectionViewDelegate> delegate;
@property(nullable, nonatomic, strong, readonly) UICollectionView *collectionView;
@property(nullable, nonatomic, copy) NSArray *recommendImageInfoArray;
@property(nullable, nonatomic, readonly) NSArray/*ExploreImageSubjectModel*/ *subjectModels;
@property (nonatomic, assign, readonly) BOOL natantVisible;
@property(nonatomic) UIEdgeInsets contentInset;
@property (nonatomic, assign, readonly) CGRect natantViewOriginFrame;
@property (nonatomic, assign) BOOL textViewOpen;//表示textView是否展开
@property (nullable, nonatomic,weak) id<UIScrollViewDelegate> cellScrolldelegate;

/**
 *  相关图集增加搜索词
 */
@property(nullable, nonatomic, copy) NSArray *recommendSearchWordsArray;

- (void)saveCurrentImage;
- (void)doShowOrHideBarsAnimationWithOrientationChanged:(BOOL)orientationChanged;
- (void)setupRecommendImageInfoArray:(nullable NSArray *)recommendImageInfoArray
          andRecommendSearchWordsArray:(nullable NSArray *)recommendSearchWordsArray;

//真的不想这么写....实在看不懂这上下文...
- (void)updateimageSubjectsFromArticle:(Article *)article;
@end

@interface ExploreImageCollectionView (ExploreImageCollectionViewDelegate) <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TTShowImageViewDelegate, UITextViewDelegate>

@end

@interface ExploreImageSubjectModel (ExploreSequence)

@property(nonatomic) NSInteger index;
@property(nonatomic) NSInteger total;

@end

@interface UIView (GrowAlphaView)

- (nonnull CAGradientLayer *)insertVerticalGrowAlphaLayerWithStartAlpha:(CGFloat)startAlpha endAlpha:(CGFloat)endAlpha;

@end

NS_ASSUME_NONNULL_END
