//
//  FHCommuteFilterView.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/21.
//

#import "FHCommuteFilterView.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UIFont+House.h>

#define TYPE_VIEW_HEIGHT 70
#define TIME_VIEW_TOP_MARGIN 30
#define TIME_VIEW_HEIGHT 100
#define SEARCH_BTN_HEIGHT 44

@interface FHCommuteFilterView ()

@property(nonatomic , strong) UIButton *searchButton;

@end

@implementation FHCommuteFilterView

-(instancetype)initWithFrame:(CGRect)frame insets:(UIEdgeInsets)insets type:(FHCommuteType) type
{
    self = [super initWithFrame:frame];
    if (self) {
 
        _typeView = [[FHCommuteTypeView alloc] initWithFrame:CGRectMake(0, insets.top, self.bounds.size.width, TYPE_VIEW_HEIGHT) ];
        [_typeView chooseType:type];
        
        _timeChooseView = [[FHCommuteChooseView alloc] initWithFrame:CGRectMake(0, _typeView.bottom+TIME_VIEW_TOP_MARGIN, self.width, TIME_VIEW_HEIGHT) type:type durationItems:@[@"15",@"30",@"40",@"50",@"60"]];
        __weak typeof(self) wself = self;
        _typeView.updateType = ^(FHCommuteType type) {
            [wself.timeChooseView chooseType:type];
        };
        
        [self addSubview:_typeView];
        [self addSubview:_timeChooseView];
 
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchButton.frame = CGRectMake(HOR_MARGIN, self.height - insets.bottom - SEARCH_BTN_HEIGHT, self.width - 2*HOR_MARGIN, SEARCH_BTN_HEIGHT);
        _searchButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _searchButton.backgroundColor = [UIColor themeRed1];
        _searchButton.titleLabel.font = [UIFont themeFontRegular:16];
        [_searchButton setTitle:@"开始找房" forState:UIControlStateNormal];
        
        [_searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_searchButton];
        
        
    }
    return self;
}

-(void)searchAction:(id)sender
{
    
}

-(void)updateType:(FHCommuteType)type time:(NSString *)time
{
    [_typeView chooseType:type];
    _timeChooseView.chooseTime = time;
}

-(FHCommuteType)type
{
    return _typeView.currentType;
}

-(NSString *)time
{
    return _timeChooseView.chooseTime;
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
