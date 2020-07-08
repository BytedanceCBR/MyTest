//
//  FHDetailEvaluationListViewHeader.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/16.
//

#import "FHDetailEvaluationListViewHeader.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "Masonry.h"
@interface FHDetailEvaluationListViewHeader ()
@property (weak, nonatomic) UIScrollView *bacScroll;
@property (strong, nonatomic) NSMutableArray *tabArr;
@end
@implementation FHDetailEvaluationListViewHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self  = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.tabArr = [[NSMutableArray alloc]init];
        [self createUI];
    }
    return self;
}

- (void)createUI {
    [self.bacScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (UIScrollView *)bacScroll {
    if (!_bacScroll) {
        UIScrollView *bacScroll = [[UIScrollView alloc]init];
        bacScroll.backgroundColor = [UIColor clearColor];
        bacScroll.showsVerticalScrollIndicator = NO;
        bacScroll.showsHorizontalScrollIndicator = NO;
        bacScroll.scrollEnabled = NO;
        [self addSubview:bacScroll];
        _bacScroll = bacScroll;
    }
    return _bacScroll;
}

- (void)setTabInfoArr:(NSArray *)tabInfoArr {
    if ([self array:_tabInfoArr isEqualTo:tabInfoArr]) {
        return;
    }else {
        if (self.tabArr.count > 0) {
            for (UIButton *btn in self.tabArr) {
                [btn removeFromSuperview];
            }
        }
    }
    _tabInfoArr = tabInfoArr;
    self.bacScroll.scrollEnabled = tabInfoArr.count>4;
    CGFloat btnWidth = 0;
    if (tabInfoArr.count<4) {
        int betWeenCount = tabInfoArr.count-1;
        btnWidth =  ([UIScreen mainScreen].bounds.size.width - 15*2 - 10*betWeenCount)/tabInfoArr.count;
    }else {
        btnWidth = ([UIScreen mainScreen].bounds.size.width - 15*2 - 10*3)/4;
    }
    CGFloat marginLeft = 10;
    CGFloat btnHeight = 30;
    UIView *leftView = self.bacScroll;
    
    for (int m = 0 ; m < _tabInfoArr.count; m ++ ) {
        NSDictionary *dic = _tabInfoArr[m];
        UIButton *btn = [[UIButton alloc]init];
        btn.layer.cornerRadius = 15;
        btn.layer.masksToBounds = YES;
        [btn setTitle:[NSString stringWithFormat:@"%@(%@)",dic[@"show_name"],dic[@"count"]] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont themeFontRegular:14];
        [btn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[self imageWithColor:[UIColor themeIMOrange]] forState:UIControlStateSelected];
        [btn setAdjustsImageWhenHighlighted:NO];
        btn.tag = m;
        btn.selected = m == 0;
        [btn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bacScroll addSubview:btn];
        [self.tabArr addObject:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            if (m == 0) {
                make.left.equalTo(leftView).offset(16);
            }else {
                make.left.equalTo(leftView.mas_right).offset(marginLeft);
            }
            make.centerY.equalTo(self.bacScroll);
            make.size.mas_equalTo(CGSizeMake(btnWidth, btnHeight));
        }];
        leftView = btn;
    }
}
- (void)tapAction:(UIButton *)btn {
    if (!btn.selected) {
        btn.selected = !btn.selected;
    }else {
        return;
    }
    for (UIButton *tab in self.tabArr) {
        if (tab.tag != btn.tag) {
            tab.selected = NO;
        }
    }
    if (self.headerItemSelectAction) {
        self.headerItemSelectAction();
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (BOOL)array:(NSArray *)array1 isEqualTo:(NSArray *)array2 {
    if (array1.count != array2.count) {
        return NO;
    }
    for (NSDictionary *dic in array1) {
        if (![array2 containsObject:dic]) {
            return NO;
        }
    }
    return YES;
}

- (NSString *)selectName {
    NSInteger index = 0;
    for (UIButton *tab in self.tabArr) {
        if (tab.selected) {
            index = tab.tag;
        };
    };
    NSDictionary *tabInfo = self.tabInfoArr[index];
    return tabInfo[@"name"];
}

- (NSString *)tracerName {
    NSInteger index = 0;
    for (UIButton *tab in self.tabArr) {
        if (tab.selected) {
            index = tab.tag;
        };
    };
    NSDictionary *tabInfo = self.tabInfoArr[index];
    return tabInfo[@"show_name"];
}
@end
