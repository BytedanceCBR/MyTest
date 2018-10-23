//
//  ExploreFavoriteListView.m
//  Article
//
//  Created by Zhang Leonardo on 14-9-14.
//
//

#import "ExploreFavoriteListView.h"
#import "ArticleTitleImageView.h"
#import "SSNavigationBar.h"
#import "UIScrollView+Refresh.h"

@interface ExploreFavoriteListView() <ExploreMixedListBaseViewDelegate>
@property (nonatomic, retain) UIView     * navigationBar;
@property(nonatomic, retain)SSThemedButton * backButton;
@property(nonatomic, retain)UIButton * rightButton;
@end

@implementation ExploreFavoriteListView

- (void)dealloc
{
    [_listView removeDelegates];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        if ([SSCommon isPadDevice]) {
            ArticleTitleImageView *titleImageView = [[ArticleTitleImageView alloc] init];
            [titleImageView setTitleText:SSLocalizedString(@"收藏", nil)];
            self.navigationBar = titleImageView;
        } else {
 
        }
        [self addSubview:self.navigationBar];
        self.navigationBar.frame = [self frameForTitleImageView];
        self.listView = [[ExploreMixedListBaseView alloc] initWithFrame:[self frameForListView] listType:ExploreOrderedDataListTypeFavorite];
        self.listView.delegate = self;
        [self addSubview:_listView];

        [_listView.listView triggerPullDown];
        [self bringSubviewToFront:self.navigationBar];
        
        ssTrackEvent(@"favorite_tab", @"enter");
    }
    return self;
}

//这里加个回调 用来enable 编辑按钮
- (void)mixListViewFinishLoad:(ExploreMixedListBaseView *)listView isFinish:(BOOL)finish
{
    self.rightButton.enabled = NO;
    if (finish) {
        if (listView.fetchListManager.items.count > 0)
            self.rightButton.enabled = YES;
        else
            self.rightButton.enabled = NO;
    }
}

- (void)willAppear
{
    [super willAppear];
    [_listView willAppear];
}

- (void)didAppear
{
    [super didAppear];
    [_listView didAppear];
}

- (void)willDisappear
{
    [super willDisappear];
    [_listView willDisappear];
}

- (void)didDisappear
{
    [super didDisappear];
    [_listView didDisappear];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.navigationBar.frame = [self frameForTitleImageView];
    _listView.frame = [self frameForListView];
}

- (void)editButtonClicked
{
    _listView.listView.editing = !_listView.listView.editing;
    [_listView.listView reloadData];
    if (_listView.listView.editing) {
        [_rightButton setTitle:SSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    }
    else {
        [_rightButton setTitle:SSLocalizedString(@"编辑", nil) forState:UIControlStateNormal];
        if (self.listView.fetchListManager.items.count > 0)
            self.rightButton.enabled = YES;
        else
            self.rightButton.enabled = NO;
    }
    
}

- (void)backButtonClicked
{
    [[self navigationController] popViewControllerAnimated:YES];
    ssTrackEvent(@"favorite_tab", @"back_button");
}

- (CGRect)frameForTitleImageView
{
    return CGRectMake(0, 0, SSWidth(self), [ArticleTitleImageView titleBarHeight]);
}

- (CGRect)frameForListView
{
    CGRect rect = CGRectMake(0, [ArticleTitleImageView titleBarHeight], SSWidth(self), SSHeight(self) - [ArticleTitleImageView titleBarHeight]);
    return rect;
}

@end
