//
//  ExploreHDMainListView.h
//  Article
//
//  Created by Zhang Leonardo on 14-9-16.
//
//

#import "SSViewBase.h"
#import "ExploreMixedListBaseView.h"

typedef NS_ENUM(NSUInteger, ExploreHDMainListViewType)
{
    ExploreHDMainListViewTypeArticle,
    ExploreHDMainListViewTypeEssay,
    ExploreHDMainListViewTypeImage
};

@interface ExploreHDMainListView : SSViewBase

@property(nonatomic, retain, readonly)ExploreMixedListBaseView * mixListView;
- (id)initWithFrame:(CGRect)frame type:(ExploreHDMainListViewType)type;

@end
