//
//  TTArticleTagView.m
//  Article
//
//  Created by 杨心雨 on 16/8/22.
//
//

#import "TTArticleTagView.h"
#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"
#import "TTDeviceHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreOrderedData+TTAd.h"

/// 标签控件
@implementation TTArticleTagView
/** 分类标签(icon)控件初始化方法 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont tt_fontOfSize:kTagViewFontSize()];
        self.layer.cornerRadius = kTagViewCornerRadius();
        self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.clipsToBounds = YES;
    }
    return self;
}

/** 分类标签(icon)布局 */
- (void)layoutTypeIcon {
    CGRect frame = CGRectZero;
    if (!isEmptyString(self.text)) {
        self.hidden = NO;
        [self sizeToFit];
        frame.size.width = self.width + kCellTypeLabelInnerPadding * 2;
        frame.size.height = kTagViewHeight();
    }
    self.frame = frame;
}
    
/**
 分类标签(icon)控件更新
 
 - parameter orderedData: OrderedData数据
 */
- (void)updateTypeIcon:(ExploreOrderedData *)orderedData {
    ExploreOrderedDataListType listType = [orderedData listType];
    if (listType >= ExploreOrderedDataListTypeTotalCount) {
        self.text = nil;
        self.hidden = YES;
        return;
    }

    // 标签展示规则
    // 收藏>推广>专题>Gif>热>荐 （如果置顶，显示置顶文案，服务端控制文案内容）
    
    if ([orderedData stickStyle] != 0) {
        self.text = orderedData.stickLabel;
    } else if ([[orderedData originalData] userRepined] == YES && listType != ExploreOrderedDataListTypeFavorite && listType != ExploreOrderedDataListTypeReadHistory &&
               listType != ExploreOrderedDataListTypePushHistory) {
        self.text = NSLocalizedString(@"收藏", @"");
    } else {
        if ([orderedData displayLabel]) {
            self.text = [orderedData displayLabel];
        } else if ([orderedData tip]) {
            NSInteger tip = [orderedData tip];
            if ((tip & 1) > 0) {
                self.text = NSLocalizedString(@"热", @"");
            } else if ((tip & 2) > 0) {
                self.text = NSLocalizedString(@"荐", @"");
            } else {
                self.text = nil;
            }
        } else {
            self.text = nil;
        }
    }
    // 除推广为蓝色外，其余均为红色
    if ([orderedData.adModel isCreativeAd] || [orderedData labelStyle] == 3 || [orderedData labelStyle] == 6) {
        self.textColorThemeKey = kTagViewTextColorBlue();
        self.borderColorThemeKey = kTagViewLineColorBlue();
    } else {
        self.textColorThemeKey = kTagViewTextColorRed();
        self.borderColorThemeKey = kTagViewLineColorRed();
    }
    
    [self layoutTypeIcon];
}

@end
