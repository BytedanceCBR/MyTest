//
//  FHMapSearchSideBar.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/7/9.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHMapSearchSideBar.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/UIImage+FIconFont.h>
#import <TTBaseLib/UIViewAdditions.h>


#define ITEM_WIDTH 36
#define ITEM_HEIGHT 60
#define ITEM_BASE_TAG 1000

@interface FHMapSearchSideBarItemView : UIControl

@property(nonatomic , strong) UIImageView *iconView;
@property(nonatomic , strong) UILabel *nameLabel;
@property(nonatomic , strong) CALayer *bottomLine;

-(instancetype)initWithType:(FHMapSearchSideBarItemType)type;

@end

@interface FHMapSearchSideBar ()

@property(nonatomic , strong) UIView *contentView;
@property(nonatomic , strong) FHMapSearchSideBarItemView *subwayItem;
@property(nonatomic , strong) FHMapSearchSideBarItemView *circleItem;
@property(nonatomic , strong) FHMapSearchSideBarItemView *filterItem;
@property(nonatomic , strong) FHMapSearchSideBarItemView *listItem;
@property(nonatomic , strong) NSArray *types;

@end

@implementation FHMapSearchSideBar


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.layer.cornerRadius = 4;
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:_contentView];
        
        _subwayItem = [self itemViewWithType:FHMapSearchSideBarItemTypeSubway];
        _circleItem = [self itemViewWithType:FHMapSearchSideBarItemTypeCircle];
        _filterItem = [self itemViewWithType:FHMapSearchSideBarItemTypeFilter];
//        _listItem   = [self itemViewWithType:FHMapSearchSideBarItemTypeList];
        
        
        _listItem.bottomLine.hidden = YES;
        
        [_contentView addSubview:_subwayItem];
        [_contentView addSubview:_circleItem];
        [_contentView addSubview:_filterItem];
//        [_contentView addSubview:_listItem];
        
        
        CALayer *layer = self.layer;
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOffset = CGSizeMake(0, 2);
        layer.shadowRadius = 6;
        layer.shadowOpacity = 0.1;
        
    }
    return self;
}


-(FHMapSearchSideBarItemView *)itemViewWithType:(FHMapSearchSideBarItemType)type
{
    FHMapSearchSideBarItemView *itemView = [[FHMapSearchSideBarItemView alloc] initWithType:type];
    itemView.tag = ITEM_BASE_TAG + type;
    [itemView addTarget:self action:@selector(onItemClickAction:) forControlEvents:UIControlEventTouchUpInside];
    return itemView;
}

-(void)showWithTypes:(NSArray *)types
{
    self.types = types;
    NSMutableDictionary *itemViewDict = @{
                                   @(FHMapSearchSideBarItemTypeSubway):self.subwayItem,
                                   @(FHMapSearchSideBarItemTypeCircle):self.circleItem,
                                   @(FHMapSearchSideBarItemTypeFilter):self.filterItem,
//                                   @(FHMapSearchSideBarItemTypeList):self.listItem,
                                   }.mutableCopy;
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:types.count];
    for (NSNumber *type in types) {
        UIView *v = itemViewDict[type];
        if (v) {
            [items addObject:v];
            [itemViewDict removeObjectForKey:type];
        }
    }
    
    
    CGFloat top = 0;
    for (FHMapSearchSideBarItemView *v in items) {
        v.top = top;
        v.left = (self.width - v.width)/2;
        top = v.bottom;
        v.hidden = NO;
        v.bottomLine.hidden = NO;
    }
    
    FHMapSearchSideBarItemView *lastItem = [items lastObject];
    lastItem.bottomLine.hidden = YES;
    
    if (itemViewDict.count > 0) {
        for (UIView *v in itemViewDict.allValues) {
            v.hidden = YES;
        }
    }
    
    self.height = (top+8);
    
}

-(NSArray *)currentTypes
{
    return self.types;
}

-(void)onItemClickAction:(FHMapSearchSideBarItemView *)item
{
    if (_chooseTypeBlock) {
        _chooseTypeBlock(item.tag - ITEM_BASE_TAG);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


@implementation FHMapSearchSideBarItemView

-(instancetype)initWithType:(FHMapSearchSideBarItemType)type
{
    self = [super initWithFrame:CGRectMake(0, 0, ITEM_WIDTH, ITEM_HEIGHT)];
    if (self) {
        NSString *iconName = nil;
        NSString *name = nil;
        switch (type) {
            case FHMapSearchSideBarItemTypeSubway:
            {
                iconName = @"\U0000e685";
                name = @"地铁";
            }
                break;
            case FHMapSearchSideBarItemTypeCircle:
            {
                iconName = @"\U0000e67c";
                name = @"画圈";
            }
                break;
            case FHMapSearchSideBarItemTypeFilter:
            {
                iconName = @"\U0000e68d";
                name = @"筛选";
            }
                break;
            case FHMapSearchSideBarItemTypeList:
            {
                iconName = @"\U0000e679";
                name = @"列表";
            }
                break;
            default:
                break;
        }
        
        UIImage *icon = ICON_FONT_IMG(20,iconName,[UIColor themeGray1]);
        self.iconView = [[UIImageView alloc] initWithImage:icon];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont themeFontRegular:12];
        _nameLabel.textColor = [UIColor themeGray1];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.text = name;
        
        [self addSubview:_iconView];
        [self addSubview:_nameLabel];
        
        _bottomLine = [CALayer layer];
        _bottomLine.backgroundColor = [[UIColor themeGray6] CGColor];
        
        [self.layer addSublayer:_bottomLine];
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.nameLabel.frame = CGRectMake(0, self.height - 17 - 6, self.width, 17);
    
    self.iconView.centerX = self.width/2;
    self.iconView.bottom = self.nameLabel.top - 4;
    
    _bottomLine.frame = CGRectMake((self.width-24)/2, self.height-1, 24, 1);
}


@end
