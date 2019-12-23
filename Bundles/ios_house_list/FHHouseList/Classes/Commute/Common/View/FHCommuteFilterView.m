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
        _searchButton.layer.cornerRadius = 4;
        _searchButton.layer.masksToBounds = YES;
        _searchButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _searchButton.backgroundColor = [UIColor themeOrange1];
        _searchButton.titleLabel.font = [UIFont themeFontRegular:16];
        [_searchButton setTitle:@"开始找房" forState:UIControlStateNormal];
        
        [_searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_searchButton];
        _enableSearch = YES;
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

-(void)searchAction:(id)sender
{
    if (!self.enableSearch) {
        return;
    }
    if (_chooseBlock) {
        _chooseBlock(self.time,self.type);
    }
}

-(void)updateType:(FHCommuteType)type time:(NSString *)time
{
    if (type >= 0) {
        [_typeView chooseType:type];
    }
    if (!IS_EMPTY_STRING(time) ) {
        _timeChooseView.chooseTime = time;
    }    
}

-(FHCommuteType)type
{
    return _typeView.currentType;
}

-(NSString *)time
{
    return _timeChooseView.chooseTime;
    
}

-(void)setEnableSearch:(BOOL)enableSearch
{
    _enableSearch = enableSearch;
    _searchButton.backgroundColor = enableSearch?[UIColor themeOrange1]:RGBA(0xff, 0x58, 0x69,0.3);
}

-(void)setBoldTitle:(BOOL)boldTitle
{
    _boldTitle = boldTitle;
    _timeChooseView.boldTitle = boldTitle;
    _typeView.boldTitle = boldTitle;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
