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
#import "FHUserTracker.h"

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
            // TODO: add by zyk 记得埋点添加，应该还有问题，原因是当sug list显示的时候上报了 猜你想搜的数据埋点
            [self trackShowEventData:item rank:button.tag];
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
        return NULL;
    } else {
        self.guessYouWangtViewHeight = 128; // 一行是89
    }
    NSInteger   line = 1;
    CGFloat     firstWordLength = [self guessYouWantTextLength:firstText];
    CGFloat     firstLineLen = firstWordLength + 10;
    CGFloat     remainWidth = UIScreen.mainScreen.bounds.size.width - 40;
    NSInteger   secondLineLen = 0;
    remainWidth -= (firstWordLength + 10);
    if (firstText.length == 0) {
        firstLineLen = 0;
        remainWidth = UIScreen.mainScreen.bounds.size.width - 40;
    }
    NSMutableArray *vArray = [array mutableCopy];
    NSMutableArray<FHGuessYouWantResponseDataDataModel>       *retArray = [NSMutableArray new];
    
    while (vArray.count > 0) {
        FHGuessYouWantResponseDataDataModel *item = [vArray firstObject];
        if (item.text.length > 0) {
            CGFloat len = [self guessYouWantTextLength:item.text];
            if (len > remainWidth) {
                NSInteger findIndex = -1;
                if (remainWidth >= 24) {
                    for (int index = 0; index < vArray.count;  index++) {
                        // 找满足长度的数据
                        FHGuessYouWantResponseDataDataModel *remainItem = vArray[index];
                        CGFloat remainLen = [self guessYouWantTextLength:remainItem.text];
                        if (remainLen <= remainWidth) {
                            // 找到
                            findIndex = index;
                            remainWidth -= (remainLen + 10);
                            if (line == 1) {
                                firstLineLen += (remainLen + 10);
                            } else if (line == 2) {
                                secondLineLen += (remainLen + 10);
                            }
                            [vArray removeObjectAtIndex:findIndex];
                            [retArray addObject:remainItem];
                            break;
                        }
                    }
                }
                if (findIndex >= 0) {
                    continue;
                } else {
                    if (line >= 2) {
                        break;
                    }
                    line += 1;
                    remainWidth = UIScreen.mainScreen.bounds.size.width - 40;
                }
            }
            remainWidth -= (len + 10);
            if (line == 1) {
                firstLineLen += (len + 10);
            } else if (line == 2) {
                secondLineLen += (len + 10);
            }
        }
        [vArray removeObjectAtIndex:0];
        [retArray addObject:item];
    }
    if (line >= 2) {
        self.guessYouWangtViewHeight = 128;
    } else {
        self.guessYouWangtViewHeight = 89;
    }

    if (firstLineLen >= secondLineLen) {
        return retArray;
    } else {
        if (count > 8) {
            [retArray removeLastObject];
            return retArray;
        }
        NSArray *tempArray = [array fh_randomArray];
        return [self firstLineGreaterThanSecond:firstText array:tempArray count:count + 1];
    }
}

- (void)buttonClick:(FHGuessYouWantButton *)btn {
    NSInteger tag = btn.tag;
    if (tag >= 0 && tag < self.guessYouWantItems.count) {
        if (_clickBlk) {
            FHGuessYouWantResponseDataDataModel *model = self.guessYouWantItems[tag];
            self.clickBlk(model);
            [self trackClickEventData:model rank:tag];
        }
    }
}

- (void)trackShowEventData:(FHGuessYouWantResponseDataDataModel *)model rank:(NSInteger)rank {
    NSString *wordType = [self wordTypeFor:model.guessSearchType];
    NSDictionary *tracerDic = @{
                                @"word":model.text.length > 0 ? model.text : @"be_null",
                                @"word_id":model.guessSearchId.length > 0 ? model.guessSearchId : @"be_null",
                                @"rank":@(rank),
                                @"word_type":wordType
                                };
    [FHUserTracker writeEvent:@"hot_word_show" params:tracerDic];
}

- (void)trackClickEventData:(FHGuessYouWantResponseDataDataModel *)model rank:(NSInteger)rank {
    NSString *wordType = [self wordTypeFor:model.guessSearchType];
    NSDictionary *tracerDic = @{
                                @"word":model.text.length > 0 ? model.text : @"be_null",
                                @"word_id":model.guessSearchId.length > 0 ? model.guessSearchId : @"be_null",
                                @"rank":@(rank),
                                @"word_type":wordType
                                };
    [FHUserTracker writeEvent:@"hot_word_click" params:tracerDic];
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
