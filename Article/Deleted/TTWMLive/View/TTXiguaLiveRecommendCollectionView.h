//
//  TTXiguaLiveRecommendCollectionView.h
//  Article
//
//  Created by lipeilun on 2017/12/5.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TTXiguaLiveRecommendUserCellType) {
    TTXiguaLiveRecommendUserCellTypeNoPicSingle = -1,   //无背景，单图，collectionView只当一个白板
    TTXiguaLiveRecommendUserCellTypeNoPic = 19,         //无背景图
    TTXiguaLiveRecommendUserCellTypeWithPic = 20,       //有背景图
};


@protocol TTXiguaLiveRecommendTrackDelegate <NSObject>
- (NSString *)xiguaLiveImpressionCategoryName;
- (NSString *)xiguaLiveImpressionCellId;
- (NSDictionary *)trackFollowParamDict;
- (NSDictionary *)trackShareParamDict;
- (NSDictionary *)trackExtraParamDict;
@end

@class TTXiguaLiveModel;
@interface TTXiguaLiveRecommendCollectionView : UICollectionView
@property (nonatomic, assign) TTXiguaLiveRecommendUserCellType cellType;
@property (nonatomic, strong) NSArray<TTXiguaLiveModel *> *cellDatas;
@property (nonatomic, weak) id<TTXiguaLiveRecommendTrackDelegate> trackDelegate;

+ (TTXiguaLiveRecommendCollectionView *)collectionViewWithLayoutType:(TTXiguaLiveRecommendUserCellType)type;
+ (CGFloat)heightWithLayoutType:(TTXiguaLiveRecommendUserCellType)type;

- (void)willDisplay;
- (void)didEndDisplaying;
@end
