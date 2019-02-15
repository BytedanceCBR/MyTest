//
//  FHHouseFindMainCell.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import "FHHouseFindMainCell.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/FHErrorView.h>

@interface FHHouseFindMainCell ()

@property(nonatomic , strong) FHErrorView *errorView;

@end

@implementation FHHouseFindMainCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.allowsMultipleSelection = YES;
        [self.contentView addSubview:_collectionView];
                
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        
    }
    return self;
}

-(FHErrorView *)errorView
{
    if (!_errorView) {
        _errorView  =[[FHErrorView alloc] initWithFrame:self.bounds];
        _errorView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_errorView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        __weak typeof(self) wself = self;
        _errorView.retryBlock = ^{
            if (wself.delegate) {
                [wself.delegate refreshInErrorView:wself];
            }
        };
        [self addSubview:_errorView];
    }
    return _errorView;
}

-(void)showErrorView:(BOOL)showError
{
    self.errorView.hidden = !showError;
}



@end
