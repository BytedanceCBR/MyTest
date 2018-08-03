//
//  TTDerailNatantRelateArticleGroupView.m
//  Article
//
//  Created by Ray on 16/4/5.
//
//

#import "SSThemed.h"
#import "TTGroupModel.h"
#import "TTDetailModel.h"
#import "ArticleInfoManager.h"
#import "TTDetailNatantRelateReadViewModel.h"
#import "TTDetailNatantRelateReadView.h"
#import "TTDetailNatantHeaderPaddingView.h"
#import "TTDetailNatantRelateArticleGroupView.h"
#import "TTDetailNatantRelateArticleGroupViewModel.h"
#import "TTDetailNatantRelateReadPlainView.h"
#import "TTUISettingHelper.h"
#import "NSString-Extension.h"
#import "TTDeviceHelper.h"
#import "SSUserSettingManager.h"

@interface TTDetailNatantRelateReadSectionView : TTDetailNatantViewBase
@property(nonatomic, strong)SSThemedLabel * titleLabel;
@property(nonatomic, assign)CGFloat left;

- (instancetype)initWithWidth:(CGFloat)width left:(CGFloat)left;

- (void)refreshTitle:(NSString *)title;

@end


#define kTitleLeftPadding 0
#define kTitleTopPadding 15

@implementation TTDetailNatantRelateReadSectionView

- (id)initWithWidth:(CGFloat)width left:(CGFloat)left
{
    self = [super initWithWidth:width];
    if (self) {
        _left = left;
        self.titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColorThemeKey = kColorText3;
        _titleLabel.font = [UIFont systemFontOfSize:12.f];
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleLabel];
        
        self.backgroundColor = [UIColor clearColor];
        [self reloadThemeUI];
    }
    return self;
}

- (void)refreshWithWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
    
    [self refreshUI];
}

- (void)refreshUI
{
    [_titleLabel sizeToFit];
    _titleLabel.origin = CGPointMake(_left, kTitleTopPadding);
    self.height = kTitleTopPadding + (_titleLabel.height);
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
}

- (void)refreshTitle:(NSString *)title
{
    _titleLabel.text = title;
    [self refreshUI];
}

@end

@implementation TTDetailNatantRelateArticleGroupView

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        
        self.backgroundColors = [TTUISettingHelper detailViewBackgroundColors];

        _items = [NSMutableArray array];
        self.viewModel = [[TTDetailNatantRelateArticleGroupViewModel alloc] init];
        self.viewModel.groupView = self;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self refreshTTDetailNatantRelatePlainView];
}

- (void)didAddSubview:(UIView *)subview
{
    if (subview) {
        [_items addObject:subview];
    }
}

- (void)themeChanged:(NSNotification *)notification{
}

- (void)fontChanged{
    for(UIView * view in self.subviews){
        if ([view isKindOfClass:[TTDetailNatantRelateReadPlainView class]]) {
            TTDetailNatantRelateReadPlainView * plainView = (TTDetailNatantRelateReadPlainView *)view;
            [plainView fontChanged];
            [plainView refreshFrame];
        }
    }
}

- (void)setRelatedItems:(NSArray<NSDictionary *> * _Nullable)relatedItems{
    self.viewModel.relatedItems = relatedItems;
}

- (NSString *)eventLabel{
    return @"related_article_show";
}

- (void)trackEventIfNeeded{
    [self sendShowTrackIfNeededForGroup:self.viewModel.articleInfoManager.detailModel.article.groupModel.groupID withLabel:self.eventLabel];
}

- (void)sendShowTrackIfNeededForGroup:(nullable NSString *)groupID withLabel:(nullable NSString *)label
{
    if (!self.hasShow) {
        if (!isEmptyString(groupID)) {
            [TTTrackerWrapper category:@"umeng"
                          event:@"detail"
                          label:label
                           dict:@{@"value":groupID}];
            self.hasShow = YES;
        }
    }
}


- (CGFloat)heightOfItemInWrapper{
    if (_items.count < 2) {
        return 0;
    }
    return [_items objectAtIndex:1].bounds.size.height;
}

- (void)checkVisableRelatedArticlesAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight{
    [self.viewModel checkVisableRelatedArticlesAtContentOffset:offsetY referViewHeight:referHeight];
}

/*
 * 计算第index个relatedItem到浮层顶部的距离
 */
- (CGFloat)relatedItemDistantFromTopToNantantTopAtIndex:(NSInteger)index
{
    //先计算wrapper位置加上“相关阅读”等sectionHeader的高度偏移，再根据index计算item的位置
    CGFloat relatedAreaTop;
    if (self.viewModel.relatedItems.count) {
        relatedAreaTop = self.top + [self itemInWrapperAtIndex:0].height;
    }
    else {
        relatedAreaTop = 0;
    }
    return relatedAreaTop + [self heightOfItemInWrapper] * index;
}

- (UIView *)itemInWrapperAtIndex:(NSInteger)index{
    return index < _items.count ? _items[index] : nil;
}

- (void)resetAllRelatedItemsWhenNatantDisappear{
    [self.viewModel resetAllRelatedItemsWhenNatantDisappear];
}

- (void)newBuildRelatedArticleViewsWithData:(ArticleInfoManager * _Nullable)infoManager {
    self.viewModel.articleInfoManager = infoManager;
    self.viewModel.relatedItems = [self.viewModel mappingOriginToModel:infoManager.ordered_info[kDetailNatantRelatedKey]];
    CGFloat wrapperHeight = 0;

    if (self.items.count == 0) {
        int i = 0;
        for (TTDetailNatantRelatedItemModel * releatedItem in self.viewModel.relatedItems) {
            if (releatedItem.title.length == 0) {
                continue;
            }
            TTDetailNatantRelateReadPlainView * view =  [TTDetailNatantRelateReadPlainView genViewForModel:releatedItem width:self.width];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            view.top = wrapperHeight;
            view.index = i;
            wrapperHeight += view.height;
            [self addSubview:view];
            i ++;
            if (i == self.viewModel.relatedItems.count) {
                [view hideBottomLine:YES];
            }
            else {
                [view hideBottomLine:NO];
            }
        }
        self.height = wrapperHeight;
    }
}

- (void)refreshTTDetailNatantRelatePlainView {
    CGFloat wrapperHeight = 0;
    for (TTDetailNatantRelateReadPlainView *view in self.items) {
        [view refreshWithWidth:self.width];
        [view refreshFrame];
        view.top = wrapperHeight;
        wrapperHeight += view.height;
    }
    if (wrapperHeight != self.height) {
        self.height = wrapperHeight;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTDetailRelateArticleGroupViewUpdate" object:nil];
    }
}


- (void)reloadData:(id)object{
    if (![object isKindOfClass:[ArticleInfoManager class]]) {
        return;
    }
    ArticleInfoManager * articleInfo = (ArticleInfoManager *)object;
    self.viewModel.articleInfoManager = articleInfo;
    [self newBuildRelatedArticleViewsWithData:articleInfo];
}

@end


