//
//  TTVDislikeAction.m
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVDislikeAction.h"
#import "TTFeedDislikeView.h"

@implementation TTVDislikeActionEntity


@end

@interface TTVDislikeAction ()

@end

@implementation TTVDislikeAction
@dynamic entity;


- (instancetype)initWithEntity:(TTVDislikeActionEntity *)entity
{
    self = [super initWithEntity:entity];
    if (self) {
        self.type = TTActivityTypeDislike;
    }
    return self;
}

#pragma mark TTFeedDislikeView

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)dislikeView {
    if (!self.entity) {
        return;
    }

    NSArray *filterWords = [dislikeView selectedWords];
    if (self.didClickDislikeSubmitButtonBlock) {
        self.didClickDislikeSubmitButtonBlock(self.entity.cellEntity, filterWords, CGRectZero, TTDislikeSourceTypeFeed);
    }
    if (self.didTrakDislikeSubmiteActionBlock){
        self.didTrakDislikeSubmiteActionBlock(filterWords);
    }
}

- (void)execute:(TTActivityType)type
{
    if (type != self.type) {
        return;
    }
    
    [TTFeedDislikeView dismissIfVisible];
    
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = self.entity.filterWords;
    viewModel.groupID = self.entity.groupId;
    viewModel.logExtra = self.entity.logExtra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = self.entity.dislikePopFromView.center;
    

    if (self.entity.dislikePopFromView) {
        [dislikeView showAtPoint:point
                        fromView:self.entity.dislikePopFromView
                 didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                     [self exploreDislikeViewOKBtnClicked:view];
                 }];
    }
}

- (void)trackAdDislikeClick
{
    
}

@end
