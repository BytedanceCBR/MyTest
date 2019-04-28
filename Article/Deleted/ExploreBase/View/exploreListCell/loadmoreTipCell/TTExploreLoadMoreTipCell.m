//
//  TTExploreLoadMoreTipCell.m
//  Article
//
//  Created by carl on 2018/1/29.
//

#import "TTExploreLoadMoreTipCell.h"

#import "ExploreMixListDefine.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTExploreLoadMoreTipData.h"
#import "TTRoute.h"
#import <Masonry.h>
#import <TTAlphaThemedButton.h>
#import "UIScrollView+Refresh.h"
#import <TTTracker.h>

@class TTExploreLoadMoreTipCellView;


@interface TTExploreLoadMoreTipCellView ()
@property (nonatomic, strong) TTAlphaThemedButton *jumpButton;
@end

@interface TTExploreLoadMoreTipCell ()

@end

@implementation TTExploreLoadMoreTipCell

+ (Class)cellViewClass {
    return [TTExploreLoadMoreTipCellView class];
}

- (void)willDisplay {
    [self.cellView willAppear];
}

- (void)didEndDisplaying {
    [self.cellView didDisappear];
}

@end

@implementation TTExploreLoadMoreTipCellView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildupView];
    }
    return self;
}

- (void)buildupView {
    TTAlphaThemedButton *button = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    button.userInteractionEnabled = NO;
    button.backgroundColorThemeKey = kColorBackground7;
    button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    button.titleColorThemeKey = kColorText12;
    button.layer.cornerRadius = 4.0f;
    button.imageName =  @"arrow_refresh_feed";
    [button layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageRight imageTitlespace:2];
    [self addSubview:button];
    self.jumpButton = button;
    [self.jumpButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(self.mas_width).multipliedBy(0.8);
        make.height.mas_equalTo(36);
    }];
}

- (void)refreshWithData:(ExploreOrderedData *)data {
    NSParameterAssert([data isKindOfClass:[ExploreOrderedData class]]);
    
    self.orderedData = data;
    TTExploreLoadMoreTipData *model = data.loadmoreTipData;
    [self.jumpButton setTitle:model.display_info forState:UIControlStateNormal];
    [self.jumpButton layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageRight imageTitlespace:2];
}

- (void)willAppear {
    TTExploreLoadMoreTipData *model = self.orderedData.loadmoreTipData;
    if (model == nil || ![model isKindOfClass:[TTExploreLoadMoreTipData class]]) {
        return;
    }
    
    CGFloat height = CGRectGetHeight(self.tableView.pullUpView.frame);
    UIEdgeInsets insect = self.tableView.contentInset;
    if (insect.bottom > 78) {
        insect.bottom -= height;
    }
    self.tableView.pullUpView.hidden = YES;
    self.tableView.contentInset = insect;
    
    [self sendTrackV3WithLable:@"category_enter_bar_show"];
}

- (NSString *)v3EnterFrom
{
    if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
        return @"click_headline";
    } else {
        return @"click_category";
    }
}

- (void)didDisappear {
   
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    TTExploreLoadMoreTipData *model = self.orderedData.loadmoreTipData;
    if (model == nil || ![model isKindOfClass:[TTExploreLoadMoreTipData class]]) {
        return;
    }
    NSURL *openURL = [NSURL URLWithString:model.openURL];
    [[TTRoute sharedRoute] openURLByViewController:openURL userInfo:nil];
    
    [self sendTrackV3WithLable:@"category_enter_bar_click"];
}

- (void)sendTrackV3WithLable:(NSString *)label {
    TTExploreLoadMoreTipData *model = self.orderedData.loadmoreTipData;
    if (model == nil || ![model isKindOfClass:[TTExploreLoadMoreTipData class]]) {
        return;
    }
    NSURL *openURL = [NSURL URLWithString:model.openURL];
    
    NSMutableDictionary *queryKeyValues = @{}.mutableCopy;
    NSArray *urlComponents = [openURL.query componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        if (pairComponents.count != 2) {
            continue;
        }
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        if (key == nil) {
            continue;
        }
        queryKeyValues[key] = value;
    }
    
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"enter_from"] = [self v3EnterFrom];
    params[@"category_name"] = self.orderedData.categoryID;
    params[@"tab_name"] = @"stream";
    params[@"position"] = @"list_bottom_bar";
    params[@"to_category_name"] = queryKeyValues[@"category"];
    [TTTracker eventV3:label params:params];
}

+ (CGFloat)heightForData:(ExploreOrderedData *)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    return 96.0f;
}

@end
