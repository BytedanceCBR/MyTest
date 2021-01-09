//
//  FHDetailNewMediaHeaderView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/25.
//

#import "FHDetailNewMediaHeaderView.h"
#import "FHVideoAndImageItemCorrectingView.h"
#import "FHCommonDefines.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>

@interface FHDetailNewMediaHeaderView ()

@property (nonatomic, strong) UILabel *totalPagesLabel;
@property (nonatomic, strong) FHVideoAndImageItemCorrectingView *itemView;   //图片户型的标签
@property (nonatomic, strong) FHDetailNewMediaHeaderScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *itemIndexArray;
@property (nonatomic, strong) NSMutableArray *itemArray;

@property (nonatomic, copy) NSArray<FHMultiMediaItemModel *> *medias;

@property (nonatomic, assign) BOOL segmentViewChangedFlag;
@end

@implementation FHDetailNewMediaHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
        [self initConstaints];
        
    }
    return self;
}

#pragma mark - UI

- (void)createUI {
    self.scrollView = [[FHDetailNewMediaHeaderScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    self.scrollView.closeInfinite = YES;
    [self addSubview:self.scrollView];

    self.itemView = [[FHVideoAndImageItemCorrectingView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
    self.itemView.btd_hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    self.itemView.hidden = YES;

    [self addSubview:self.itemView];

    self.totalPagesLabel = [[UILabel alloc] init];
    self.totalPagesLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.totalPagesLabel.textAlignment = NSTextAlignmentCenter;
    self.totalPagesLabel.font = [UIFont themeFontRegular:12];
    self.totalPagesLabel.textColor = [UIColor whiteColor];
    self.totalPagesLabel.layer.cornerRadius = 11;
    self.totalPagesLabel.layer.masksToBounds = YES;
    [self addSubview:self.totalPagesLabel];

    __weak typeof(self) wSelf = self;
    self.itemView.selectedBlock = ^(NSInteger index, NSString *_Nonnull name, NSString *_Nonnull value) {
        [wSelf selectItem:index];
    };
    self.scrollView.didSelectiItemAtIndex = ^(NSInteger index) {
        if (wSelf.didSelectiItemAtIndex) {
            wSelf.didSelectiItemAtIndex(index);
        }
    };

    self.scrollView.scrollToIndex = ^(NSInteger index) {
        [wSelf updateItemAndInfoLabel:index];
    };

    self.scrollView.willDisplayCellForItemAtIndex = ^(NSInteger index) {
        if (wSelf.willDisplayCellForItemAtIndex) {
            wSelf.willDisplayCellForItemAtIndex(index);
        }
    };
    
    self.scrollView.goToPictureListFrom = ^(NSString * _Nonnull name) {
        if (wSelf.goToPictureListFrom) {
            wSelf.goToPictureListFrom(name);
        }
    };
}

- (void)initConstaints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];

    [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self.scrollView.mas_bottom).offset(-15);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];

    [self.totalPagesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(54);
        make.height.mas_equalTo(22);
        make.right.mas_equalTo(self.scrollView.mas_right).offset(-9);
        make.bottom.mas_equalTo(self.scrollView.mas_bottom).offset(-15);
    }];
    [self layoutIfNeeded];
}

- (void)updateMultiMediaModel:(FHMultiMediaModel *)model {
    self.medias = model.medias.copy;
    [self.scrollView updateModel:model];

    self.itemArray = [NSMutableArray array];
    self.itemIndexArray = [NSMutableArray array];
    for (NSInteger i = 0; i < self.medias.count; i++) {
        FHMultiMediaItemModel *itemModel = self.medias[i];
        if (![_itemArray containsObject:itemModel.groupType]) {
            [_itemArray addObject:itemModel.groupType];
            [self.itemIndexArray addObject:@(i)];
        }
    }
    if (_itemArray.count > 1) {
        self.itemView.hidden = NO;
        [self setNeedsLayout];
        [self layoutIfNeeded];
        [self.itemView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.itemArray.count * 44);
        }];
        CGRect frame = self.itemView.frame;
        frame.size.width = self.itemArray.count * 44;
        self.itemView.frame = frame;
        [self.itemView setNeedsLayout];
        self.itemView.titleArray = _itemArray;
        [self.itemView selectedItem:_itemArray[0]];
    } else {
        self.itemView.hidden = YES;
    }
}

#pragma mark - operator
- (void)setTotalPagesLabelText:(NSString *)text {
    self.totalPagesLabel.text = text;
}

- (void)selectItem:(NSInteger)index {
    if (index < 0 || index >= self.itemIndexArray.count) {
        return;
    }
    NSInteger item = [self.itemIndexArray[index] integerValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    
    self.segmentViewChangedFlag = YES;
    [self.scrollView scrollToItemAtIndexPath:indexPath animated:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.segmentViewChangedFlag = NO;
    });

    if (self.didClickItemViewName) {
        self.didClickItemViewName(self.itemArray[index]);
    }
}

- (void)updateItemAndInfoLabel:(NSInteger)index {
    NSLog(@"segmentViewChangedFlag %d",self.segmentViewChangedFlag);
    if (self.segmentViewChangedFlag) {
        return;
    }
    if (index >= 0 && index < self.medias.count) {
        FHMultiMediaItemModel *itemModel = self.medias[index];
        NSString *groupType = itemModel.groupType;
        [self.itemView selectedItem:groupType];
    }
}

@end
