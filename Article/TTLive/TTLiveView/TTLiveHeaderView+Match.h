//
//  TTLiveHeaderView+Match.h
//  Article
//
//  Created by matrixzk on 8/11/16.
//
//

#import "TTLiveHeaderView.h"

@interface TTLiveHeaderView () <UIActionSheetDelegate>

@property (nonatomic, weak) UIView *matchTeamView;
@property (nonatomic, weak) UILabel *matchStartDateLabel;
@property (nonatomic, weak) UILabel *matchSubtitleLabel;
//@property (nonatomic, weak) UILabel *matchStatusLabel;
@property (nonatomic, weak) UILabel *matchScoreLeftLabel;
@property (nonatomic, weak) UILabel *matchScoreRightLabel;
@property (nonatomic, weak) UIView *matchScoreView;

@property (nonatomic, strong) NSMutableArray *matchVideoLinkBtnArray;
//@property (nonatomic, strong) NSArray *currentVideoSourceDetailArray;
@property (nonatomic, weak) TTLiveMatchVideoH5SourceInfo *currentVideoSourceInfo;

@end

@interface TTLiveHeaderView (Match)

- (void)setupSubviews4LiveTypeMatch;
- (void)refreshMatchStatusWithModel:(TTLiveStreamDataModel *)model;

@end
