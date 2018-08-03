//
//  TTRecommendRedpacketCell.m
//  Article
//
//  Created by lipeilun on 2017/10/24.
//

#import "TTRecommendRedpacketCell.h"
#import "TTRecommendRedpacketCellView.h"
#import "RecommendRedpacketData.h"


@interface TTRecommendRedpacketCell()
@property (nonatomic, strong) TTRecommendRedpacketCellView *redpacketCellView;
@end

@implementation TTRecommendRedpacketCell

+ (Class)cellViewClass {
    return [TTRecommendRedpacketCellView class];
}

- (ExploreCellViewBase *)redpacketCellView {
    if (!_redpacketCellView) {
        _redpacketCellView = [[TTRecommendRedpacketCellView alloc] initWithFrame:self.bounds];
    }
    
    return _redpacketCellView;
}

- (void)willDisplay {
    [(TTRecommendRedpacketCellView *)self.cellView willAppear];
}

- (void)didEndDisplaying {
    [(TTRecommendRedpacketCellView *)self.cellView didDisappear];
}

- (void)dealloc {
    
}

@end
