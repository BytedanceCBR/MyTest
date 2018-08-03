//
//  TTPopularHashtagCollectionView.h
//  Article
//
//  Created by lipeilun on 2018/1/17.
//

#import <UIKit/UIKit.h>

@protocol TTPopularHashtagTrackDelegate <NSObject>
- (NSString *)popularHashtagImpressionCategoryName;
- (NSString *)popularHashtagImpressionCellId;
@end

@interface TTPopularHashtagCollectionView : UICollectionView
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, strong) NSArray<FRForumStructModel *> *cellDatas;
@property (nonatomic, weak) id<TTPopularHashtagTrackDelegate> trackDelegate;

+ (TTPopularHashtagCollectionView *)collectionView;

- (void)willDisplay;
- (void)didEndDisplaying;
@end
