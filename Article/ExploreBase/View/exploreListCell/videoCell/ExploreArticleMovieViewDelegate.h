//
//  ExploreArticleMovieViewDelegate.h
//  Article
//
//  Created by Chen Hong on 15/8/31.
//
//

#import <Foundation/Foundation.h>
#import "ExploreMovieView.h"

typedef void (^shareActionBlock)(NSString *activityType);
typedef void (^movieViewWillMoveToSuperView)(UIView *newView);
@interface ExploreArticleMovieViewDelegate : NSObject<ExploreMovieViewDelegate>

@property(nonatomic,strong)ExploreOrderedData *orderedData;
@property(nonatomic, strong)UIView *logo;
@property(nonatomic, copy)dispatch_block_t shareButtonClickedBlock;
@property(nonatomic, copy)dispatch_block_t playerShareButtonClickedBlock;
@property(nonatomic, copy)dispatch_block_t moreButtonClickedBlock;
@property(nonatomic, copy)dispatch_block_t replayButtonClickedBlock;
@property(nonatomic, strong)shareActionBlock shareActionClickedBlock;
@property(nonatomic, copy)movieViewWillMoveToSuperView movieViewWillAppear;
@property(nonatomic, weak)SSViewBase *viewBase;
@end
