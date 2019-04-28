//
//  TTHTSWaterfallCollectionView.h
//  Article
//
//  Created by 王双华 on 2017/4/12.
//
//

#import "ArticleBaseListView.h"

@interface TTHTSWaterfallCollectionView : ArticleBaseListView

- (instancetype)initWithFrame:(CGRect)frame topInset:(CGFloat)topinset bottomInset:(CGFloat)bottomInset;

- (void)setRefreshFromType:(ListDataOperationReloadFromType)refreshFromType;

- (BOOL)tt_hasValidateData;

- (void)refreshListViewForCategory:(TTCategory *)category isDisplayView:(BOOL)display fromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote reloadFromType:(ListDataOperationReloadFromType)fromType listEntrance:(NSString *)listEntrance;

@end
