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
#import "UIImage+FIconFont.h"

@interface FHHistoryView ()

@property (nonatomic, strong)   UILabel       *label;
@property (nonatomic, strong)   NSMutableArray       *tempViews;
@property (nonatomic, strong)   FHExtendHotAreaButton *deleteBtn;
@property (nonatomic, assign)   BOOL isLimited;
@property (nonatomic, strong) NSMutableDictionary *dict;
@property (nonatomic, strong) NSMutableDictionary *isTractedDict;

@end

@implementation FHHistoryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isLimited = YES;
        _dict = [NSMutableDictionary new];
        _isTractedDict = [NSMutableDictionary new];
        self.backgroundColor = [UIColor whiteColor];
        self.historyViewHeight = 89; // 一行是89
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
        make.top.mas_equalTo(10);
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
    if (self.vc.isCanTrack) {
        [self.dict enumerateKeysAndObjectsUsingBlock:^(NSString  *key, NSDictionary *obj, BOOL * _Nonnull stop) {
            if (!_isTractedDict[key] && [obj isKindOfClass:[NSDictionary class]]) {
                _isTractedDict[key] = @1;
                [FHUserTracker writeEvent:@"search_history_show" params:obj];
            }
        }];
    }
}

- (void)moreButtonClick
{
    _isLimited = NO;
    if (self.moreClick) {
        [self reAddViews];
        self.moreClick();
    }
}

- (void)reAddViews {
    for (UIView *v in self.tempViews) {
        [v removeFromSuperview];
    }
    self.historyViewHeight = 94;
    [self.tempViews removeAllObjects];
    NSInteger   line = 1;
    CGFloat     lastTopOffset = 50;
    UIView *    leftView = self;
    CGFloat     remainWidth = UIScreen.mainScreen.bounds.size.width - 30;
    NSInteger   currentIndex = 0;
    BOOL        isFirtItem = YES;
    for (FHSuggestionSearchHistoryResponseDataDataModel* item in self.historyItems) {
        if (item.text.length > 0) {
            FHHistoryButton *button = [[FHHistoryButton alloc] init];
            button.label.text = item.text;
            CGSize size = [button.label sizeThatFits:CGSizeMake(201, 17)];
            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width - 42;
            if (size.width > screenWidth) {
                size.width = screenWidth;
            }
            size.width += 12;
            if (_isLimited && remainWidth < size.width && size.width + 42 > [UIScreen mainScreen].bounds.size.width - 30 && currentIndex < self.historyItems.count - 1) {
                size.width -= 42;
            }
            CGFloat limitWidth = _isLimited ? 42 : 0;
            button.tag = currentIndex;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            if (size.width + limitWidth > remainWidth) {
                // 下一行
                if (line >= 2 && _isLimited) {
                    // 两行加载不完
                    if (currentIndex < self.historyItems.count - 1 || size.width > remainWidth) {
                        FHHistoryButton *moreButton = [[FHHistoryButton alloc] init];
                        UIImageView *imageView = [[UIImageView alloc] initWithImage:ICON_FONT_IMG(16, @"\U0000e672", [UIColor themeGray3])];
                        imageView.frame = CGRectMake(8, 8, 16, 16);
                        [moreButton addSubview:imageView];
                        [self addSubview:moreButton];
                        [moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
                        [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
                           make.left.mas_equalTo(leftView.mas_right).offset(10);
                            make.top.mas_equalTo(self).offset(lastTopOffset);
                            make.width.mas_equalTo(32);
                            make.height.mas_equalTo(32);
                        }];
                        [_tempViews addObject:moreButton];
                        break;
                    }
                }
                if (size.width > remainWidth) {
                    line += 1;
                    lastTopOffset += 42;
                    _historyViewHeight += 42;
                    leftView = self;
                    isFirtItem = YES;
                    remainWidth = UIScreen.mainScreen.bounds.size.width - 30;
                }
            }
            remainWidth -= (size.width + 10);
            [self addSubview:button];
            // 布局
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                if (isFirtItem) {
                    make.left.mas_equalTo(self).offset(15);
                } else {
                    make.left.mas_equalTo(leftView.mas_right).offset(10);
                }
                make.top.mas_equalTo(self).offset(lastTopOffset);
                make.width.mas_equalTo(size.width);
                make.height.mas_equalTo(32);
            }];
            [self historyShow:item andRank:currentIndex];
            isFirtItem = NO;
            leftView = button;
            [_tempViews addObject:button];
        }
        currentIndex += 1;
    }
}


- (void)historyShow:(FHSuggestionSearchHistoryResponseDataDataModel *)model andRank:(NSInteger)rank
{
    NSString *key = [NSString stringWithFormat:@"%p", model];
    NSDictionary *tracerDic = @{
                                @"word":model.text.length > 0 ? model.text : @"be_null",
                                @"history_id":model.historyId.length > 0 ? model.historyId : @"be_null",
                                @"rank":@(rank),
                                @"show_type":@"list"
                                };
    _dict[key] = tracerDic;
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