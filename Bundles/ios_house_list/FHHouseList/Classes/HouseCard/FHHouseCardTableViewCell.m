//
//  FHHouseCardTableViewCell.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/10.
//

#import "FHHouseCardTableViewCell.h"
#import "FHHouseNewComponentViewModel.h"
#import "FHHouseCardCellViewModelProtocol.h"

@interface FHHouseCardTableViewCell()<FHHouseNewComponentViewModelObserver>

@end

@implementation FHHouseCardTableViewCell
@synthesize viewModel = _viewModel;

- (void)dealloc {
    [self.viewModel removeObserver:self];
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [_viewModel removeObserver:self];
    _viewModel = viewModel;
    [_viewModel addObserver:self];
}

- (void)cellWillShowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.viewModel conformsToProtocol:@protocol(FHHouseCardCellViewModelProtocol)]) {
        id<FHHouseCardCellViewModelProtocol> cardViewModel = (id<FHHouseCardCellViewModelProtocol>)self.viewModel;
        if ([cardViewModel respondsToSelector:@selector(showCardAtIndexPath:)]) {
            [cardViewModel showCardAtIndexPath:indexPath];
        }
    }
}

- (void)cellDidEndShowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.viewModel conformsToProtocol:@protocol(FHHouseCardCellViewModelProtocol)]) {
        id<FHHouseCardCellViewModelProtocol> cardViewModel = (id<FHHouseCardCellViewModelProtocol>)self.viewModel;
        if ([cardViewModel respondsToSelector:@selector(hideCardAtIndexPath:)]) {
            [cardViewModel hideCardAtIndexPath:indexPath];
        }
    }
}

- (void)cellDidClickAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.viewModel conformsToProtocol:@protocol(FHHouseCardCellViewModelProtocol)]) {
        id<FHHouseCardCellViewModelProtocol> cardViewModel = (id<FHHouseCardCellViewModelProtocol>)self.viewModel;
        if ([cardViewModel respondsToSelector:@selector(clickCardAtIndexPath:)]) {
            [cardViewModel clickCardAtIndexPath:indexPath];
        }
    }
}

- (void)cellWillEnterForground {
    if ([self.viewModel conformsToProtocol:@protocol(FHHouseCardCellViewModelProtocol)]) {
        id<FHHouseCardCellViewModelProtocol> cardViewModel = (id<FHHouseCardCellViewModelProtocol>)self.viewModel;
        if ([cardViewModel respondsToSelector:@selector(cardWillEnterForground)]) {
            [cardViewModel cardWillEnterForground];
        }
    }
}

- (void)cellDidEnterBackground {
    if ([self.viewModel conformsToProtocol:@protocol(FHHouseCardCellViewModelProtocol)]) {
        id<FHHouseCardCellViewModelProtocol> cardViewModel = (id<FHHouseCardCellViewModelProtocol>)self.viewModel;
        if ([cardViewModel respondsToSelector:@selector(cardDidEnterBackground)]) {
            [cardViewModel cardDidEnterBackground];
        }
    }
}

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if ([self respondsToSelector:@selector(calculateViewHeight:)]) {
        if (viewModel.needCalculateHeight) {
            viewModel.cachedHeight = [self calculateViewHeight:viewModel];
            viewModel.needCalculateHeight = NO;
        }
        return viewModel.cachedHeight;
    }
    
    return 0.0f;
}

@end
