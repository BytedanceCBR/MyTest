//
//  TTRecommendUserCollectionViewWrapper.h
//  Article
//
//  Created by lipeilun on 2017/6/19.
//
//

#import "TTRecommendUserCollectionView.h"
#import "SSThemed.h"

@interface TTRecommendUserCollectionViewWrapper : SSThemedView
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTRecommendUserCollectionView *collectionView;
- (instancetype)initWithFrame:(CGRect)frame isWeitoutiao:(BOOL)isWeitoutiao;
@end
