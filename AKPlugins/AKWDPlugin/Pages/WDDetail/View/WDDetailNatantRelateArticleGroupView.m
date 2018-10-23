//
//  WDDetailNatantRelateArticleGroupView.m
//  Article
//
//  Created by 延晋 张 on 16/4/26.
//
//

#import "WDDetailNatantRelateArticleGroupView.h"
#import "WDDetailModel.h"
#import "WDDetailNatantRelateArticleGroupViewModel.h"
#import "WDDetailNatantRelateWendaView.h"
#import "WDAnswerEntity.h"

#import "TTGroupModel.h"
#import "SSThemed.h"
#import "TTDeviceHelper.h"

#define kDetailNatantRelatedKey @"kDetailNatantRelated"

@interface WDDetailNatantRelateArticleGroupView ()

@property (nonatomic, strong) SSThemedView *topLineView;
@property (nonatomic, strong) SSThemedView *bottomLineView;

@end

@implementation WDDetailNatantRelateArticleGroupView

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        [self reloadThemeUI];
        _items = [NSMutableArray array];
        self.viewModel = [[WDDetailNatantRelateArticleGroupViewModel alloc] init];
        self.viewModel.groupView = self;
        
        self.topLineView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel])];
        self.topLineView.backgroundColorThemeKey = kColorLine1;
        self.topLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.topLineView];
        
        self.bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel])];
        self.bottomLineView.backgroundColorThemeKey = kColorLine1;
        self.bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.bottomLineView];
    }
    return self;
}

- (void)didAddSubview:(UIView *)subview
{
    if (subview) {
        [_items addObject:subview];
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
}

- (void)setRelatedItems:(NSArray<NSDictionary *> * _Nullable)relatedItems{
    self.viewModel.relatedItems = relatedItems;
}

- (NSString *)eventLabel{
    return @"related_article_show";
}

- (void)trackEventIfNeeded{
    [self sendShowTrackIfNeededForGroup:self.viewModel.detailModel.answerEntity.ansid withLabel:self.eventLabel];
}

- (void)sendShowTrackIfNeededForGroup:(nullable NSString *)groupID withLabel:(nullable NSString *)label
{
    if (!self.hasShow) {
        self.hasShow = YES;
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

- (void)newBuildRelatedArticleViewsWithData:(WDDetailModel * _Nullable)detailModel{
    CGFloat relateAreaLastItemBottomPadding = 6.f;
    self.viewModel.detailModel = detailModel;
    self.viewModel.relatedItems = [self.viewModel mappingOriginToModel:detailModel.ordered_info[kDetailNatantRelatedKey]];
    CGFloat wrapperHeight = 0;
    
    int i = 0;
    for (WDDetailNatantRelatedItemModel * releatedItem in self.viewModel.relatedItems) {
        WDDetailNatantRelateWendaView * view =  [WDDetailNatantRelateWendaView genViewForModel:releatedItem width:self.width];
        view.detailModule = detailModel;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        view.top = wrapperHeight;
        wrapperHeight += view.height;
        [self addSubview:view];
        i ++;
        if (i == self.viewModel.relatedItems.count) {
            view.height += relateAreaLastItemBottomPadding;
            [view hideBottomLine:YES];
        }
        else {
            [view hideBottomLine:NO];
        }
    }
    self.height = wrapperHeight + relateAreaLastItemBottomPadding;
    [self bringSubviewToFront:self.topLineView];
    [self bringSubviewToFront:self.bottomLineView];
}

-(void)reloadData:(id)object{
    if (![object isKindOfClass:[WDDetailModel class]]) {
        return;
    }
    WDDetailModel * detailModel = (WDDetailModel *)object;
    self.viewModel.detailModel = detailModel;
    [self newBuildRelatedArticleViewsWithData:detailModel];
}

@end
