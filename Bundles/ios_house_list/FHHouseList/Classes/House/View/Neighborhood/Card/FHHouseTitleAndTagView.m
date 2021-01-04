//
//  FHHouseTitleAndTagView.m
//  FHHouseList
//
//  Created by bytedance on 2020/11/11.
//

#import "FHHouseTitleAndTagView.h"
#import "Masonry.h"
#import "FHHouseTagView.h"
#import "FHHouseTagViewModel.h"
#import "UIFont+House.h"
#import "FHHouseTitleAndTagViewModel.h"
#import "UIViewAdditions.h"

@interface FHHouseTitleAndTagView() {
    NSMutableArray *_titleTagViews;
}
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation FHHouseTitleAndTagView

+ (CGFloat)calculateViewHeight:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseTitleAndTagViewModel.class]) return 0.0f;
    FHHouseTitleAndTagViewModel *tagViewModel = (FHHouseTitleAndTagViewModel *)viewModel;
    return [tagViewModel showHeight];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleTagViews = [NSMutableArray array];
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.titleLabel];
}

- (void)setupConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (void)refreshOpacity:(CGFloat)opacity {
    self.titleLabel.layer.opacity = opacity;
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    FHHouseTitleAndTagViewModel *titleAndTagViewModel = (FHHouseTitleAndTagViewModel *)self.viewModel;
    self.titleLabel.attributedText = titleAndTagViewModel.attributedTitle;
    if (_titleTagViews.count < titleAndTagViewModel.tags.count) {
        for (NSInteger index = _titleTagViews.count; index < [titleAndTagViewModel.tags count]; index++) {
            FHHouseTagView *tagView = [[FHHouseTagView alloc] init];
            [_titleTagViews addObject:tagView];
        }
    } else if (_titleTagViews.count > titleAndTagViewModel.tags.count) {
        for (NSInteger index = _titleTagViews.count - 1; index >= (NSInteger)[titleAndTagViewModel.tags count]; index--) {
            FHHouseTagView *tagView = _titleTagViews[index];
            [tagView removeFromSuperview];
        }
        [_titleTagViews removeObjectsInRange:NSMakeRange(titleAndTagViewModel.tags.count, _titleTagViews.count - titleAndTagViewModel.tags.count)];
    }
    CGFloat left = 0.0f;
    for (NSInteger index = 0; index < [_titleTagViews count]; index++) {
        FHHouseTagViewModel *tagViewModel = titleAndTagViewModel.tags[index];
        FHHouseTagView *tagView = _titleTagViews[index];
        if (index > 0) {
            left += 2;
        }
        tagView.frame = CGRectMake(left, 3, tagViewModel.tagWidth, tagViewModel.tagHeight);
        tagView.viewModel = tagViewModel;
        [self addSubview:tagView];
        left += tagView.width;
    }
}

@end
