//
//  ExploreHDMainListView.m
//  Article
//
//  Created by Zhang Leonardo on 14-9-16.
//
//

#import "ExploreHDMainListView.h"
#import "MultipleLineCategoryView.h"
#import "ArticleTitleImageView.h"
#import "ArticleCategoryManager.h"
#import "ExploreMixedListView.h"
#import "NewsListLogicManager.h"
#import "ArticleCityView.h"
#import "UIScrollView+Refresh.h"

@interface ExploreHDMainListView()<MultipleLineCategoryViewDelegate>
{
    BOOL _hasDidAppeared;
}
@property(nonatomic, retain)MultipleLineCategoryView *padArticleCategorySelectorView;
@property(nonatomic, retain)ArticleTitleImageView *titleImageView;
@property(nonatomic, assign)ExploreHDMainListViewType padUIListType;
@property(nonatomic, retain)ExploreMixedListBaseView * mixListView;
@end

@implementation ExploreHDMainListView

- (void)dealloc
{
    [_mixListView removeDelegates];
    self.padArticleCategorySelectorView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (id)initWithFrame:(CGRect)frame type:(ExploreHDMainListViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.padUIListType = type;
        [self buildTitleImageView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryGotFinished:) name:kAritlceCategoryGotFinishedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCityDidChangedNotification:) name:kArticleCityDidChangedNotification object:nil];
    }
    return self;
}


- (void)buildTitleImageView
{
    self.titleImageView = [[ArticleTitleImageView alloc] initWithFrame:[self frameForTitleBarView]];
    
    self.mixListView = [[ExploreMixedListBaseView alloc] initWithFrame:[self frameForListView] listType:ExploreOrderedDataListTypeCategory];
    
    [self addSubview:_mixListView];
    
    self.padArticleCategorySelectorView = [[MultipleLineCategoryView alloc] initWithFrame:[self frameForCategorySelectorView]
                                                                                    style:CategorySelectStyleSetSelectLineToFirst];
    _padArticleCategorySelectorView.delegate = self;
    [self addSubview:_padArticleCategorySelectorView];

    
}

- (void)reloadForCategory:(CategoryModel *)model
{
    if ([model isKindOfClass:[CategoryModel class]] && isEmptyString(model.categoryID)) {
        return;
    }
    _mixListView.categoryID = model.categoryID;
    [_mixListView refreshHeaderViewShowSearchBar:NO];
    
    BOOL shouldFromRemote = [[NewsListLogicManager shareManager] shouldAutoReloadFromRemoteForCategory:model.categoryID];
    
    if (shouldFromRemote) {
        [_mixListView.listView triggerPullDown];
    }
    else
        [_mixListView fetchFromLocal:YES fromRemote:shouldFromRemote getMore:NO];
}

#pragma mark -- category

- (void)categorySelectorReloadCategorys
{
    NSArray * categorys = [self currentCategorys];
    [_padArticleCategorySelectorView refreshWithCategories:categorys];
}

- (NSArray *)currentCategorys
{
    NSArray * categorys = nil;
    if (_padUIListType == ExploreHDMainListViewTypeEssay) {
        categorys = [[ArticleCategoryManager sharedManager] essayCatgegories];
    }
    else if (_padUIListType == ExploreHDMainListViewTypeImage) {
        categorys = [[ArticleCategoryManager sharedManager] imageCategories];
    }
    else {
        categorys = [[ArticleCategoryManager sharedManager] articleCategories];
    }
    return categorys;
}

#pragma mark -- life cycle

- (void)willAppear
{
    [super willAppear];
    [_mixListView willAppear];
}

- (void)didAppear
{
    [super didAppear];
    if (!_hasDidAppeared) {
        [self categorySelectorReloadCategorys];
        NSArray * categorys = [self currentCategorys];
        if ([categorys count] > 0) {
            id first = [categorys objectAtIndex:0];
            if ([first isKindOfClass:[CategoryModel class]]) {
                CategoryModel * model = (CategoryModel *)first;
                [self reloadForCategory:model];
            }
        }
        _hasDidAppeared = YES;
    }
    [_mixListView didAppear];
}

- (void)willDisappear
{
    [super willDisappear];
    [_mixListView willDisappear];
}

- (void)didDisappear
{
    [super didDisappear];
    [_mixListView didDisappear];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _mixListView.frame = [self frameForListView];
    setFrameWithWidth(_padArticleCategorySelectorView, SSWidth(self));
}

#pragma mark -- receive notification

- (void)categoryGotFinished:(NSNotification*)notification
{
    [self categorySelectorReloadCategorys];
}

- (void)receiveCityDidChangedNotification:(NSNotification *)notification
{
    [self categorySelectorReloadCategorys];
}


#pragma mark -- frame

- (CGRect)frameForListView
{
    return CGRectMake(0, SSMaxY(_padArticleCategorySelectorView), SSWidth(self), SSHeight(self) - SSMaxY(_padArticleCategorySelectorView));
}

- (CGRect)frameForTitleBarView
{
    return CGRectMake(0, 0, self.frame.size.width, 64);
}

- (CGRect)frameForCategorySelectorView
{
    return CGRectMake(0, 0, SSWidth(self), 64);
}


#pragma mark --  MultipleLineCategoryViewDelegate

- (void)multipleLineCategoryView:(MultipleLineCategoryView *)view selectCategory:(CategoryModel *)category categoryView:(UIView *)categoryView
{
    if (category) {
        [self reloadForCategory:category];
        [_mixListView scrollToTopAnimated:NO];
    }
}

- (void)multipleLineCategoryView:(MultipleLineCategoryView *)view sizeWillChangeTo:(CGSize)size duration:(float)duration
{
    _mixListView.frame = [self frameForListView];
}


@end
