//
//  FHGuessYouWantView.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHGuessYouWantView.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"

@interface FHGuessYouWantView ()

@property (nonatomic, strong)   UILabel       *label;
@property (nonatomic, strong)   NSMutableArray       *tempViews;

@end

@implementation FHGuessYouWantView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.guessYouWangtViewHeight = 128; // 一行是89
        self.tempViews = [NSMutableArray new];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // label
    _label = [[UILabel alloc] init];
    _label.text = @"猜你想搜";
    _label.font = [UIFont themeFontMedium:14];
    _label.textColor = [UIColor themeBlue1];
    [self addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
}

- (void)setGuessYouWantItems:(NSArray *)guessYouWantItems {
    _guessYouWantItems = guessYouWantItems;
    [self reAddViews];
}

- (void)reAddViews {
    for (UIView *v in self.tempViews) {
        [v removeFromSuperview];
    }
    [self.tempViews removeAllObjects];
    NSInteger   line = 1;
    CGFloat     lastTopOffset = 50;
    UIView *    leftView = self;
    CGFloat     remainWidth = UIScreen.mainScreen.bounds.size.width - 40;
    NSInteger   currentIndex = 0;
    BOOL        isFirtItem = YES;
    for (FHGuessYouWantResponseDataDataModel* item in self.guessYouWantItems) {
        if (item.text.length > 0) {
            FHGuessYouWantButton *button = [[FHGuessYouWantButton alloc] init];
            button.label.text = item.text;
            CGSize size = [button.label sizeThatFits:CGSizeMake(121, 17)];
            if (size.width > 120) {
                size.width = 120;
            }
            size.width += 12;
            button.tag = currentIndex;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            if (size.width > remainWidth) {
                // 下一行
                if (line >= 2) {
                    // 已经添加完成
                    break;
                }
                line += 1;
                lastTopOffset = 89;
                leftView = self;
                isFirtItem = YES;
                remainWidth = UIScreen.mainScreen.bounds.size.width - 40;
            }
            remainWidth -= (size.width + 10);
            [self addSubview:button];
            // 布局
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                if (isFirtItem) {
                    make.left.mas_equalTo(self).offset(20);
                } else {
                    make.left.mas_equalTo(leftView.mas_right).offset(10);
                }
                make.top.mas_equalTo(self).offset(lastTopOffset);
                make.width.mas_equalTo(size.width);
                make.height.mas_equalTo(29);
            }];
            isFirtItem = NO;
            leftView = button;
            [_tempViews addObject:button];
            // TODO: add by zyk 记得埋点添加
        }
        currentIndex += 1;
    }
}

- (CGFloat)guessYouWantTextLength:(NSString *)text
{
    FHGuessYouWantButton *button = [[FHGuessYouWantButton alloc] init];
    button.label.text = text;
    CGSize size = [button.label sizeThatFits:CGSizeMake(121, 17)];
    if (size.width > 120) {
        size.width = 120;
    }
    size.width += 12;
    return size.width;
}

- (NSArray<FHGuessYouWantResponseDataDataModel>       *)firstLineGreaterThanSecond:(NSString *)firstText array:(NSArray<FHGuessYouWantResponseDataDataModel> *)array count:(NSInteger)count {
    // 计算猜你想搜高度
    if (array.count <= 0) {
        self.guessYouWangtViewHeight = CGFLOAT_MIN;
    } else {
        self.guessYouWangtViewHeight = 128; // 一行是89
    }
    return array;
}

- (void)buttonClick:(FHGuessYouWantButton *)btn {
    
}

@end

// ---

@implementation FHGuessYouWantButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor colorWithHexString:@"#f2f4f5"];
    self.layer.cornerRadius = 4.0;
    _label = [[UILabel alloc] init];
    _label.numberOfLines = 1;
    _label.font = [UIFont themeFontRegular:12];
    _label.textColor = [UIColor themeBlue1];
    [self addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self).offset(6);
        make.bottom.right.mas_equalTo(self).offset(-6);
        make.width.mas_lessThanOrEqualTo(120);
        make.height.mas_equalTo(17);
    }];
}

@end
