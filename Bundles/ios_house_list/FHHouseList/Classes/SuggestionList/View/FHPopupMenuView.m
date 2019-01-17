//
//  FHPopupMenuView.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/23.
//

#import "FHPopupMenuView.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHHouseTypeManager.h"

@interface FHPopupMenuView ()

@property (nonatomic, strong)   UIView       *popMenuContainer;
@property (nonatomic, weak)     UIView       *targetView;
@property (nonatomic, strong)   NSArray       *menus;

@end

@implementation FHPopupMenuView

- (instancetype)initWithTargetView:(UIView *)weakTargetView menus:(NSArray *)menus
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.targetView = weakTargetView;
        self.menus = menus;
        [self setupUI];
        [self addTarget:self action:@selector(popupClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)popupClick {
    [self removeFromSuperview];
}

- (void)setupUI {
    _popMenuContainer = [[UIView alloc] init];
    _popMenuContainer.layer.shadowOffset = CGSizeMake(0, 2);
    _popMenuContainer.layer.shadowRadius = 4.0;
    _popMenuContainer.layer.shadowColor = UIColor.blackColor.CGColor;
    _popMenuContainer.layer.shadowOpacity = 0.1;
    _popMenuContainer.backgroundColor = UIColor.whiteColor;
}

- (void)showOnTargetView {
    [self addSubview:_popMenuContainer];
    CGRect frame = [self.targetView convertRect:self.targetView.frame toView:self.superview];
    [self.popMenuContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(frame.origin.y + frame.size.height);
        make.left.mas_equalTo(frame.origin.x);
        make.width.mas_equalTo(80);
    }];
    __block UIView *lastView = self.popMenuContainer;
    NSInteger count = self.menus.count;
    [self.menus enumerateObjectsUsingBlock:^(FHPopupMenuItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHPopupMenuItemView *menuView = [[FHPopupMenuItemView alloc] init];
        [self.popMenuContainer addSubview:menuView];
        menuView.label.text = [[FHHouseTypeManager sharedInstance] stringValueForType:obj.houseType];
        if (obj.isSelected) {
            menuView.label.textColor = [UIColor colorWithHexString:@"#299cff"];
        } else {
            menuView.label.textColor = [UIColor colorWithHexString:@"#505050"];
        }
        menuView.menuItem = obj;
        [menuView addTarget:self action:@selector(menuClick:) forControlEvents:UIControlEventTouchUpInside];
        // masonry
        [menuView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (idx == 0) {
                make.top.mas_equalTo(self.popMenuContainer.mas_top);
            } else {
                make.top.mas_equalTo(lastView.mas_bottom);
            }
            make.left.right.mas_equalTo(self.popMenuContainer);
            if (idx == count - 1) {
                make.bottom.mas_equalTo(self.popMenuContainer.mas_bottom);
            }
        }];
        lastView = menuView;
    }];
}

- (void)menuClick:(FHPopupMenuItemView *)itemView {
    if (itemView.menuItem.itemClickBlock) {
        itemView.menuItem.itemClickBlock(itemView.menuItem.houseType);
    }
}

@end

// ----

@interface FHPopupMenuItem ()

@end

@implementation FHPopupMenuItem

- (instancetype)initWithHouseType:(FHHouseType)ht isSelected:(BOOL)isSelected
{
    self = [super init];
    if (self) {
        self.houseType = ht;
        self.isSelected = isSelected;
    }
    return self;
}

@end

// ----

@interface FHPopupMenuItemView ()

@end

@implementation FHPopupMenuItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _label = [[UILabel alloc] init];
    _label.highlightedTextColor = [UIColor colorWithHexString:@"#f85959"];
    _label.textColor = [UIColor colorWithHexString:@"#505050"];
    _label.font = [UIFont themeFontRegular:14];
    _label.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10);
        make.right.mas_equalTo(self).offset(-10);
        make.top.bottom.mas_equalTo(self);
        make.height.mas_equalTo(35);
    }];
}

@end
