//
//  WDCommentReposNatantHeaderView.m
//  Article
//
//  Created by ranny_90 on 2017/9/20.
//
//

#import "WDCommentReposNatantHeaderView.h"
#import "WDDetailModel.h"
#import "WDAnswerEntity.h"
#import "SSThemed.h"
#import <KVOController.h>
#import <ReactiveObjC/ReactiveObjC.h>

static const CGFloat kLeftRightMargin = 15.0f;
static const CGFloat kFontSize = 14.0f;
static const CGFloat kTabHeight = 50.0f;

@interface WDCommentReposNatantHeaderView()

@property (nonatomic, strong) SSThemedLabel *allCommentsLabel;
@property (nonatomic, strong) SSThemedLabel *digUsersLabel;
@property (nonatomic, strong) SSThemedView *separatorLine;

@property (nonatomic, strong) WDDetailModel *detailModel;

@end

@implementation WDCommentReposNatantHeaderView

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithWidth:width];
    if (self) {
        [self addSubview:self.allCommentsLabel];
        [self addSubview:self.digUsersLabel];
        [self addSubview:self.separatorLine];
    }
    return self;
}

- (void)reloadData:(id)object {
    [super reloadData:object];
    if ([object isKindOfClass:[WDDetailModel class]]) {
        
        self.detailModel = object;
        
        WeakSelf;
        [self.KVOController observe:self.detailModel.answerEntity keyPath:@keypath(self.detailModel.answerEntity, diggCount) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            [self updateDigUsersLabel];
        }];
        
        [self.KVOController observe:self.detailModel.answerEntity keyPath:@keypath(self.detailModel.answerEntity, commentCount) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            [self updateAllCommentsLabel];
        }];
        
        [self updateAllCommentsLabel];
        [self updateDigUsersLabel];
    }
    [self refreshUI];
}


- (void)updateDigUsersLabel {
    
    NSString *digText = [NSString stringWithFormat:@"%@ 赞", self.detailModel.answerEntity.diggCount ?: @"0"];
    NSMutableDictionary *attributedTextInfo = [NSMutableDictionary dictionary];
    [attributedTextInfo setValue:digText forKey:kSSThemedLabelText];
    [attributedTextInfo setValue:kColorText1 forKey:NSStringFromRange(NSMakeRange(0, digText.length - 1))];
    [attributedTextInfo setValue:kColorText1 forKey:NSStringFromRange(NSMakeRange(digText.length - 1, 1))];
    self.digUsersLabel.attributedTextInfo = attributedTextInfo;
    [self refreshUI];
}

- (void)updateAllCommentsLabel {
    self.allCommentsLabel.text = [NSString stringWithFormat:@"评论 %@",self.detailModel.answerEntity.commentCount ?: @"0"];
    [self refreshUI];
}

- (void)refreshUI {
    [super refreshUI];
    self.height = [TTDeviceUIUtils tt_newPadding:kTabHeight];
    self.allCommentsLabel.height = self.height;
    self.digUsersLabel.height = self.height;
    
    [self.allCommentsLabel sizeToFit];
    [self.digUsersLabel sizeToFit];
    
    CGFloat allCommentsLabelWidth = CGRectGetWidth(self.allCommentsLabel.frame) + 2*[TTDeviceUIUtils tt_newPadding:kLeftRightMargin];
    self.allCommentsLabel.frame = CGRectMake(0, 0, allCommentsLabelWidth, self.height);
    
    CGFloat digUserLabelWidth = CGRectGetWidth(self.digUsersLabel.frame) + 2*[TTDeviceUIUtils tt_newPadding:kLeftRightMargin];
    self.digUsersLabel.frame = CGRectMake(self.width - digUserLabelWidth, 0, digUserLabelWidth, self.height);
    
    self.separatorLine.frame = CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
}

#pragma mark - KVO


#pragma mark - actions

- (void)digUserLabelTapped:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
//
//        TTArticleMomentDigUsersViewController *controller = [[TTArticleMomentDigUsersViewController alloc] initWithCommentID:self.viewModel.commentRepostModel.commentId diggCount:self.viewModel.commentRepostModel.actionDataModel.digg_count.longLongValue];
//        controller.isBanShowAuthor = YES;
//        controller.sourceFrom = TTArticleMomentDigUserSourceCommentRepostDetail;
//        controller.gid = _groupId;
//        controller.categoryName = _categoryName;
//        controller.fromPage = self.pageState.from == TTCommentDetailSourceTypeThread ? @"detail_topic_comment_dig" : (self.pageState.from == TTCommentDetailSourceTypeDetail ? @"detail_article_comment_dig" : @"");
        
//        [self.navigationController pushViewController:controller animated:YES];
        
//        FRThreadDigUserViewController *controller = [[FRThreadDigUserViewController alloc] initWithThreadID:self.viewModel.commentRepostModel.commentId.longLongValue
//                                                                                               authorUserID:self.viewModel.commentRepostModel.userModel.info.user_id];
//        controller.forumID = self.viewModel.forum.forum_id;
//        controller.trackExtra = [self.viewModel.dataSource extraTracks];
//        [[TTUIResponderHelper topNavigationControllerFor:self] pushViewController:controller animated:YES];
    }
    
}

#pragma mark - accessors

- (SSThemedLabel *)allCommentsLabel {
    if (!_allCommentsLabel) {
        _allCommentsLabel = [[SSThemedLabel alloc] init];
        _allCommentsLabel.text = @"评论";
        _allCommentsLabel.textAlignment = NSTextAlignmentCenter;
        _allCommentsLabel.textColorThemeKey = kColorText1;
        _allCommentsLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kFontSize]];
    }
    return _allCommentsLabel;
}

- (SSThemedLabel *)digUsersLabel {
    if (!_digUsersLabel) {
        _digUsersLabel = [[SSThemedLabel alloc] init];
        _digUsersLabel.text = @"赞";
        _digUsersLabel.textAlignment = NSTextAlignmentCenter;
        _digUsersLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kFontSize]];
        _digUsersLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(digUserLabelTapped:)];
        [_digUsersLabel addGestureRecognizer:recognizer];
        _digUsersLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    return _digUsersLabel;
}

- (SSThemedView *)separatorLine {
    if (!_separatorLine) {
        _separatorLine = [[SSThemedView alloc] init];
        _separatorLine.backgroundColorThemeKey = kColorLine1;
        _separatorLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _separatorLine;
}

@end

