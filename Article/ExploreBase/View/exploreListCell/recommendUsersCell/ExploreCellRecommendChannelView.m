//
//  ExploreCellRecommendChannelView.m
//  Article
//
//  Created by Chen Hong on 14/11/26.
//
//

#import "ExploreCellRecommendChannelView.h"
#import "SSAppPageManager.h"
#import "ArticleCategoryManager.h"

#import "CategorySelectorView.h"
#import "ArticleCategoryManager.h"
#import "NewsBaseDelegate.h"
#import "TTIndicatorView.h"
#import "TTStringHelper.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"

@interface ExploreCellRecommendChannelView ()
@property(nonatomic,strong)TTCategory *categoryModel;
@end

@implementation ExploreCellRecommendChannelView

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCategoryChanged:) name:kInsertCategoryToLastPositionNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCategoryChanged:) name:kArticleCategoryHasChangeNotification object:nil];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
}

- (void)setChannelModel:(ExploreEmbedListChannelModel *)channelModel {
    _channelModel = channelModel;
    self.nameLabel.text = channelModel.name;
    [self.avatarView setImageWithURLString:channelModel.iconURLString placeholderImage:nil];

    if (!isEmptyString(channelModel.desc)) {
        self.descLabel.text = channelModel.desc;
    } else {
        self.descLabel.text = @"";
    }
    //[self refreshRelationButtonType];
    if (!isEmptyString(channelModel.reason)) {
        self.recommendReasonLabel.text = channelModel.reason;
    } else {
        self.recommendReasonLabel.text = @"";
    }
    
    if (_channelModel.nextCellType == ExploreOrderedDataCellTypeCard) {
        if (!self.bottomLineView.hidden) {
            self.bottomLineView.hidden = YES;
            [self setNeedsDisplay];
        }
    } else {
        if (self.bottomLineView.hidden) {
            self.bottomLineView.hidden = NO;
            [self setNeedsDisplay];
        }
    }
    
    self.categoryModel = [ArticleCategoryManager categoryModelByCategoryID:self.channelModel.destCategoryId];
}

- (void)viewDidTapped {
    if (!isEmptyString(self.channelModel.openUrl)) {
        [[SSAppPageManager sharedManager] openURL:[TTStringHelper URLWithURLString:self.channelModel.openUrl]];
        
        // feed流卡片推荐频道
        if (self.isCardSubView) {
            ssTrackEvent(@"card", [NSString stringWithFormat:@"click_category_%ld", (long)self.cardSubCellIndex]);
        }
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:@"channel_detail" forKey:@"tag"];
        [dict setValue:[NSString stringWithFormat:@"click_%@", self.channelModel.categoryID] forKey:@"label"];
        [dict setValue:self.channelModel.destCategoryId forKey:@"category_id"];
        [self trackClickEvent:dict];
    }
}

- (void)relationButtonClicked:(id)sender
{
    [self subscribe:nil];
}

#pragma mark - FriendDataManagerDelegate

//- (void)refreshRelationButtonType
//{
//    if ([self shouldShowAddButton]) {
//        self.buttonType = RecomChannelViewButtonTypeNotAdded;
//        self.relationButton.enabled = YES;
//    } else {
//        self.buttonType = RecomChannelViewButtonTypeAdded;
//        self.relationButton.enabled = NO;
//    }
//}

- (void)setButtonType:(RecomChannelViewButtonType)buttonType
{
    _buttonType = buttonType;
    
    [self refreshRelationButton];
}

- (void)refreshRelationButton
{
//    NSString * titleStr = nil;
//
//    switch (_buttonType) {
//        case RecomChannelViewButtonTypeNotAdded:
//        {
//            titleStr = NSLocalizedString(@"添加", nil);
//        }
//            break;
//
//        case RecomChannelViewButtonTypeAdded:
//        {
//            titleStr = NSLocalizedString(@"已添加", nil);
//        }
//            break;
//            
//        default:
//            break;
//    }
    
//    if (!isEmptyString(titleStr)) {
//        [self.relationButton setTitle:titleStr forState:UIControlStateNormal];
//    }
//        

}

- (BOOL)shouldShowAddButton {
    BOOL showAddButton = YES;

    TTCategory *model = [self queryCategoryModel];
    
    if (![TTDeviceHelper isPadDevice]) {
        CategorySelectorView *selectorView = [self categorySelectorView];
        
        // 检查频道是否位于首页
        BOOL bVisible = [selectorView isCategoryInFirstScreen:self.channelModel.destCategoryId];
        BOOL hasBadge = [selectorView isCategoryShowBadge:self.channelModel.destCategoryId];
        BOOL hasSubscribed = model.subscribed;
        
        showAddButton = (!bVisible && !hasBadge) || !hasSubscribed;
    } else {
        showAddButton = !model.subscribed;
    }

    return showAddButton;
}

// 取得categorySelectorView
- (CategorySelectorView *)categorySelectorView {
    
    return [(NewsBaseDelegate*)[[UIApplication sharedApplication] delegate] categorySelectorView];
}

- (void)subscribe:(id)sender
{
    TTCategory *model = [self queryCategoryModel];
    
    if (model) {
        if (self.buttonType == RecomChannelViewButtonTypeNotAdded) {
            NSDictionary *userInfo = @{kInsertCategoryNotificationCategoryKey:model};
            [[NSNotificationCenter defaultCenter] postNotificationName:kInsertCategoryToLastPositionNotification object:nil userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:kArticleCategoryTipNewChangedNotification object:nil];
            
            //self.subscribeViewContainer.hidden = YES;
            if (![TTDeviceHelper isPadDevice]) {
                //[[SSActivityIndicatorView sharedView] showInView:nil message:NSLocalizedString(@"已放到首页", nil)];
            } else {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"频道已添加", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }

            self.buttonType = RecomChannelViewButtonTypeAdded;
            
            if (self.isCardSubView) {
                ssTrackEvent(@"card", [NSString stringWithFormat:@"add_category_%ld", (long)self.cardSubCellIndex]);
            }
            
            NSString *eventLabel = [NSString stringWithFormat:@"add_%@", self.channelModel.categoryID];
            
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
            [dict setValue:@"channel_detail" forKey:@"tag"];
            [dict setValue:eventLabel forKey:@"label"];
            [dict setValue:self.channelModel.destCategoryId forKey:@"category_id"];
            [self trackClickEvent:dict];
            
            [self showSubscribeAnimation];
        }
    }
}

- (void)showSubscribeAnimation {
    if ([TTDeviceHelper isPadDevice]) {
        return;
    }
    SSImageView *motionView = [[SSImageView alloc] initWithFrame:self.avatarView.frame];
    motionView.layer.cornerRadius = self.avatarView.layer.cornerRadius;
    [motionView setImageWithURLString:_channelModel.iconURLString placeholderImage:nil];
    UIWindow * applicationWindow = [[[UIApplication sharedApplication] delegate] window];
    motionView.center = [applicationWindow convertPoint:motionView.center fromView:self];
    [applicationWindow addSubview:motionView];
    
    motionView.alpha = 1.f;
    motionView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    
    UIView *button = [[self categorySelectorView] categorySelectorButtonByCategoryId:self.channelModel.destCategoryId];
    
    if (!button) {
        button = [self categorySelectorView].expandButton;
    }
    
    CGPoint dest = [applicationWindow convertPoint:button.center fromView:button.superview];
    
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        motionView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        motionView.center = dest;
    } completion:^(BOOL finished) {
        motionView.alpha = 0.f;
        [motionView removeFromSuperview];
    }];
}

- (TTCategory *)queryCategoryModel {
    TTCategory *categoryModel = [ArticleCategoryManager categoryModelByCategoryID:self.channelModel.destCategoryId];
    if (!categoryModel) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:self.channelModel.destCategoryId forKey:@"category"];
        [dict setValue:self.channelModel.name forKey:@"name"];
        [dict setValue:self.channelModel.type forKey:@"type"];
        [dict setValue:self.channelModel.webUrl forKey:@"web_url"];
        [dict setValue:self.channelModel.flags forKey:@"flags"];
        
        categoryModel = [ArticleCategoryManager insertCategoryWithDictionary:dict];
    }
    return categoryModel;
}

//- (void)onCategoryChanged:(NSNotification *)notification {
//    [self refreshRelationButtonType];
//}

@end
