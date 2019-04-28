//
//  ExploreMixedListView.h
//  Article
//
//  Created by Zhang Leonardo on 14-9-5.
//
//

#import "SSViewBase.h"
#import "ArticleBaseListView.h"
#import "ExploreMixedListBaseView.h"


@interface ExploreMixedListView : ArticleBaseListView

@property (nonatomic, retain) ExploreMixedListBaseView *listView;
@property (nonatomic, assign) TTCategoryModelTopType tabType;

- (instancetype)initWithFrame:(CGRect)frame topInset:(CGFloat)inset bottomInset:(CGFloat)bottomInset;

- (instancetype)initWithFrame:(CGRect)frame
                     topInset:(CGFloat)inset
                  bottomInset:(CGFloat)bottomInset
                     listType:(ExploreOrderedDataListType)type
                 listLocation:(ExploreOrderedDataListLocation)listLocation;

- (instancetype)initWithFrame:(CGRect)frame
                     topInset:(CGFloat)inset
                  bottomInset:(CGFloat)bottomInset
                     listType:(ExploreOrderedDataListType)type
                 listLocation:(ExploreOrderedDataListLocation)listLocation
                      fromTab:(TTCategoryModelTopType)tabType;

@end
