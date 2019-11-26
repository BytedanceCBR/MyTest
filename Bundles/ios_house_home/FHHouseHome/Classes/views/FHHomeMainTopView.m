//
//  FHHomeMainTopView.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import "FHHomeMainTopView.h"
#import <HMSegmentedControl.h>
#import "UIColor+Expanded.h"
#import <UIFont+House.h>
#import <UIColor+Theme.h>

@interface FHHomeMainTopView()
@property(nonatomic,strong)HMSegmentedControl *segmentControl;
@end

@implementation FHHomeMainTopView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setupSetmentedControl {
    _segmentControl = [[HMSegmentedControl alloc] initWithSectionTitles:[self getSegmentTitles]];
    
    NSDictionary *titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:16],
                                          NSForegroundColorAttributeName: [UIColor themeGray3]};
    _segmentControl.titleTextAttributes = titleTextAttributes;
    
    NSDictionary *selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontMedium:18],
                                                  NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.selectedTitleTextAttributes = selectedTitleTextAttributes;
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    _segmentControl.isNeedNetworkCheck = NO;
    _segmentControl.segmentEdgeInset = UIEdgeInsetsMake(9, 10, 0, 10);
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentControl.selectionIndicatorWidth = 24.0f;
    _segmentControl.selectionIndicatorHeight = 12.0f;
    _segmentControl.selectionIndicatorImage = [UIImage imageNamed:@"fh_ugc_segment_selected"];
    
    [self addSubview:_segmentControl];
    
    __weak typeof(self) weakSelf = self;
    _segmentControl.indexChangeBlock = ^(NSInteger index) {
    };
    
    _segmentControl.indexRepeatBlock = ^(NSInteger index) {
    };
}

- (NSArray *)getSegmentTitles {
    return @[@"首页", @"发现"];
}

@end
