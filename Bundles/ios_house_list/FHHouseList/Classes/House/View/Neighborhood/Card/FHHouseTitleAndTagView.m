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
    CGFloat lineHeight = tagViewModel.titleFont.lineHeight;
    CGFloat height = [tagViewModel.attributedTitle boundingRectWithSize:CGSizeMake(tagViewModel.maxWidth, lineHeight * 2 + 1) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    return ceil(height);
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

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    FHHouseTitleAndTagViewModel *titleAndTagViewModel = (FHHouseTitleAndTagViewModel *)self.viewModel;
    self.titleLabel.attributedText = titleAndTagViewModel.attributedTitle;
    
    
    if (_titleTagViews.count < titleAndTagViewModel.tags.count) {
        for (NSInteger index = _titleTagViews.count; index < [titleAndTagViewModel.tags count]; index++) {
            FHHouseTagViewModel *tagViewModel = titleAndTagViewModel.tags[index];
            FHHouseTagView *tagView = [[FHHouseTagView alloc] initWithFrame:CGRectMake(0, 3, tagViewModel.tagWidth, tagViewModel.tagHeight)];
            tagView.viewModel = tagViewModel;
            [_titleTagViews addObject:tagView];
        }
    } else if (_titleTagViews.count > titleAndTagViewModel.tags.count) {
        [_titleTagViews removeObjectsInRange:NSMakeRange(titleAndTagViewModel.tags.count, _titleTagViews.count - titleAndTagViewModel.tags.count)];
    }
    
    CGFloat left = 0.0f;
    for (NSInteger index = 0; index < [_titleTagViews count]; index++) {
        FHHouseTagView *tagView = _titleTagViews[index];
        if (index > 0) {
            left += 2;
        }
        tagView.left = left;
        [self addSubview:tagView];
        left += tagView.width;
    }
}

@end
