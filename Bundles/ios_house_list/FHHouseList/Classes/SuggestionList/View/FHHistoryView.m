//
//  FHGuessYouWantView.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHHistoryView.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"
#import "FHUserTracker.h"
#import "BDImageView.h"
#import "UIImageView+BDWebImage.h"
#import "FHExtendHotAreaButton.h"

@interface FHHistoryView ()

@property (nonatomic, strong)   UILabel       *label;
@property (nonatomic, strong)   NSMutableArray       *tempViews;
@property (nonatomic, strong)   FHExtendHotAreaButton *deleteBtn;
@end

@implementation FHHistoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.historyViewHeight = 128; // 一行是89
        self.tempViews = [NSMutableArray new];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // label
    _label = [[UILabel alloc] init];
    _label.text = @"历史记录";
    _label.font = [UIFont themeFontMedium:16];
    _label.textColor = [UIColor themeGray1];
    [self addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(20);
    }];
    _deleteBtn = [[FHExtendHotAreaButton alloc] init];
    [_deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [self addSubview:_deleteBtn];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.right.mas_equalTo(-11);
        make.centerY.mas_equalTo(self.label);
    }];
    [_deleteBtn addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)deleteButtonClick:(UIButton *)btn {
    if (self.delClick) {
        self.delClick();
    }
}

- (void)setHistoryItems:(NSArray *)historyItems {
    
    _historyItems = historyItems;
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
    for (FHSuggestionSearchHistoryResponseDataDataModel* item in self.historyItems) {
        if (item.text.length > 0) {
            FHHistoryButton *button = [[FHHistoryButton alloc] init];
            button.label.text = item.text;
            CGSize size = [button.label sizeThatFits:CGSizeMake(201, 17)];
            if (size.width > 200) {
                size.width = 200;
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
        }
        currentIndex += 1;
    }
}

- (CGFloat)historyTextLength:(NSString *)text
{
    FHHistoryButton *button = [[FHHistoryButton alloc] init];
    button.label.text = text;
    CGSize size = [button.label sizeThatFits:CGSizeMake(121, 17)];
    if (size.width > 120) {
        size.width = 120;
    }
    size.width += 12;
    return size.width;
}

- (void)buttonClick:(FHHistoryButton *)btn {
    NSInteger tag = btn.tag;
    if (tag >= 0 && tag < self.historyItems.count) {
        if (_clickBlk) {
            FHSuggestionSearchHistoryResponseDataDataModel *model = self.historyItems[tag];
            self.clickBlk(model, tag);
        }
    }
}

- (NSString *)wordTypeFor:(NSString *)guessSearchType {
    NSInteger type = [guessSearchType integerValue];
    NSString *retStr = @"";
    switch (type) {
        case 1:
            retStr = @"operation";
            break;
        case 2:
            retStr = @"hot";
            break;
        case 3:
            retStr = @"history";
            break;
        default:
            retStr = @"be_null";
            break;
    }
    return retStr;
}

@end

// ---

@implementation FHHistoryButton

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
    self.backgroundColor = [UIColor themeGray7];
    self.layer.cornerRadius = 4.0;
    _label = [[UILabel alloc] init];
    _label.numberOfLines = 1;
    _label.font = [UIFont themeFontRegular:12];
    _label.textColor = [UIColor themeGray1];
    [self addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self).offset(6);
        make.bottom.right.mas_equalTo(self).offset(-6);
        make.width.mas_lessThanOrEqualTo(120);
        make.height.mas_equalTo(17);
    }];
}

@end

@implementation NSArray (FHSort)

- (NSArray *)fh_randomArray {
    // 转为可变数组
    NSMutableArray * tmp = self.mutableCopy;
    // 获取数组长度
    NSInteger count = tmp.count;
    // 开始循环
    while (count > 0) {
        // 获取随机角标
        NSInteger index = arc4random_uniform((int)(count - 1));
        // 获取角标对应的值
        id value = tmp[index];
        // 交换数组元素位置
        tmp[index] = tmp[count - 1];
        tmp[count - 1] = value;
        count--;
    }
    // 返回打乱顺序之后的数组
    return tmp.copy;
}

@end


@implementation FHHistoryFirstWords

- (instancetype)init
{
    self = [super init];
    if (self) {
        _wordLine = 0;
        _wordLength = 0;
    }
    return self;
}

@end
