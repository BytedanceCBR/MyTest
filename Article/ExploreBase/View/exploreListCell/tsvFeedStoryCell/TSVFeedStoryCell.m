//
//  TSVFeedStoryCell.m
//  Article
//
//  Created by dingjinlu on 2018/1/9.
//

#import "TSVFeedStoryCell.h"
#import <ReactiveObjC.h>
#import "TSVStoryCollectionViewCell.h"
#import "TSVStoryViewModel.h"
#import "TSVStoryOriginalData.h"
#import "ExploreOrderedData+TTBusiness.h"
#import <TTUIWidget/TTAlphaThemedButton.h>
#import "TTShortVideoHelper.h"
#import "TSVStoryContainerView.h"

#define kRectPadding            6

@implementation TSVFeedStoryCell

+ (Class)cellViewClass
{
    return [TSVFeedStoryCellView class];
}

- (void)willAppear
{
    if ([self.cellView isKindOfClass:[TSVFeedStoryCellView class]]) {
        [((TSVFeedStoryCellView *)self.cellView) willDisplay];
    }
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    if ([self.cellView isKindOfClass:[TSVFeedStoryCellView class]]) {
        [((TSVFeedStoryCellView *)self.cellView) didEndDisplaying];
    }
    
}

- (void)willDisplay
{
    if ([self.cellView isKindOfClass:[TSVFeedStoryCellView class]]) {
        [((TSVFeedStoryCellView *)self.cellView) willDisplay];
    }
}

- (void)didEndDisplaying
{
    if ([self.cellView isKindOfClass:[TSVFeedStoryCellView class]]) {
        [((TSVFeedStoryCellView *)self.cellView) didEndDisplaying];
    }
}

@end


@interface TSVFeedStoryCellView()

@property (nonatomic, strong) TSVStoryContainerView         *storyView;
@property (nonatomic, strong) SSThemedView                  *topRect;
@property (nonatomic, strong) SSThemedView                  *bottomRect;
@property (nonatomic, strong) TTAlphaThemedButton           *unInterestedButton;

@property (nonatomic, strong) ExploreOrderedData            *orderedData;
@property (nonatomic, strong) TSVStoryOriginalData          *originalData;
@property (nonatomic, assign) BOOL                          isDisplaying;

@end


@implementation TSVFeedStoryCellView
+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    ExploreOrderedData *orderedData = data;
    CGFloat height = [TSVStoryContainerView heightForModel:orderedData.tsvStoryOriginalData.storyModel];
    
    if (![orderedData nextCellHasTopPadding]) {
        height += kRectPadding;
    }
    if (![orderedData preCellHasBottomPadding]) {
        height += kRectPadding;
    }
    return height;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerEnterForegroundNotification];
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
        self.originalData = self.orderedData.tsvStoryOriginalData;
        
        NSString *listEntrance;
        if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
            listEntrance = @"more_shortvideo";
        } else if ([self.orderedData.categoryID isEqualToString:kTTFollowCategoryID]) {
            listEntrance = @"more_shortvideo_guanzhu";
        }
        
        TSVStoryViewModel *viewModel = [[TSVStoryViewModel alloc] initWithModel:self.originalData.storyModel listEntrance:listEntrance];
        viewModel.orderedData = self.orderedData;
        viewModel.categoryName = self.orderedData.categoryID;

        self.storyView.viewModel = viewModel;
    }
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    self.topRect.width = self.width;
    self.topRect.height = kRectPadding;
    
    self.bottomRect.width = self.width;
    self.bottomRect.height = kRectPadding;
    
    if ([self.orderedData preCellHasBottomPadding]) {
        CGRect bounds = self.bounds;
        bounds.origin.y = 0;
        self.bounds = bounds;
        self.topRect.hidden = YES;
    } else {
        CGRect bounds = self.bounds;
        bounds.origin.y = -kRectPadding;
        self.bounds = bounds;
        self.topRect.bottom = 0;
        self.topRect.width = self.width;
        self.topRect.hidden = NO;
    }
    
    if (!([self.orderedData nextCellHasTopPadding])) {
        self.bottomRect.bottom = self.height + self.bounds.origin.y;
        self.bottomRect.width = self.width;
        self.bottomRect.hidden = NO;
    } else {
        self.bottomRect.hidden = YES;
    }

    self.storyView.top = self.topRect.bottom;
    self.storyView.width = self.width;
    self.storyView.height = [TSVStoryContainerView heightForModel:self.originalData.storyModel];
    
    self.unInterestedButton.left = self.storyView.width - 53;
    self.unInterestedButton.centerY = 20;
    
    [self reloadThemeUI];
}

- (SSThemedView *)topRect
{
    if (!_topRect) {
        _topRect = [[SSThemedView alloc] init];
        _topRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_topRect];
    }
    return _topRect;
}

- (SSThemedView *)bottomRect
{
    if (!_bottomRect) {
        _bottomRect = [[SSThemedView alloc] init];
        _bottomRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_bottomRect];
    }
    return _bottomRect;
}

- (TTAlphaThemedButton *)unInterestedButton
{
    if (!_unInterestedButton) {
        _unInterestedButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _unInterestedButton.imageName = @"add_textpage.png";
        _unInterestedButton.backgroundColor = [UIColor clearColor];
        [_unInterestedButton addTarget:self action:@selector(unInterestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.storyView addSubview:_unInterestedButton];
    }
    return _unInterestedButton;
}

- (TSVStoryContainerView *)storyView
{
    if (!_storyView) {
        _storyView = [[TSVStoryContainerView alloc] initWithFrame:CGRectZero];
        [self addSubview:_storyView];
    }
    return _storyView;
}
#pragma mark -

- (void)willDisplay
{
    _isDisplaying = YES;
    
    [self.storyView willDisplay];
    [self.storyView.viewModel trackShowEvent];
}

- (void)didEndDisplaying
{
    _isDisplaying = NO;
    
    [self.storyView didEndDisplaying];
}

- (void)registerEnterForegroundNotification
{
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        if (_isDisplaying) {
            [self.storyView.viewModel trackShowEvent];
        }
    }];
}

#pragma mark - unInterestButton action

- (void)unInterestButtonClicked:(id)sender
{
    [TTShortVideoHelper uninterestFormView:self.unInterestedButton point:self.unInterestedButton.center withOrderedData:self.orderedData];
}

@end
