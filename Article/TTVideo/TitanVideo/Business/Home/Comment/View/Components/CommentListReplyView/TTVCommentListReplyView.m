//
//  TTVCommentListReplyView.m
//  Article
//
//  Created by lijun.thinker on 2017/5/25.
//
//

#import "TTVCommentListReplyView.h"
//#import "TTCommentReplyModel.h"
#import "SSThemed.h"
#import "TTRoute.h"
#import "NetworkUtilities.h"
#import "TTIndicatorView.h"

#define kTopPadding [TTDeviceUIUtils tt_newPadding:12.f]

extern UIColor *tt_ttuisettingHelper_detailViewCommentReplyBackgroundColor(void);

@interface TTVCommentListReplyView () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) SSThemedView *wrapper;
@property(nonatomic, strong) SSThemedTableView *replyTableView;
@property(nonatomic, strong) id <TTVCommentModelProtocol> toComment;
@property(nonatomic, strong) NSArray<TTVCommentListReplyModel *> *replyArr;
@property(nonatomic, copy) TTVCommentReplyActionBlock replyActionBlock;
@property(nonatomic, copy) TTVCommentReplyActionBlock replyUserBlock;

@end

@implementation TTVCommentListReplyView

- (instancetype)initWithWidth:(CGFloat)width toComment:(id <TTVCommentModelProtocol>)toComment
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        _toComment = toComment;
        _replyArr = [TTVCommentListReplyModel replyListForComment:toComment];
        [self buildReplyTableView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithWidth:frame.size.width toComment:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithFrame:CGRectZero];
}

- (void)didClickReplyToMakeAction:(TTVCommentReplyActionBlock)block
{
    if (block) {
        self.replyActionBlock = block;
    }
}

- (void)didClickReplyToViewUser:(TTVCommentReplyActionBlock)block
{
    if (block) {
        self.replyUserBlock = block;
    }
}

- (void)buildReplyTableView
{
    CGRect rect = CGRectMake(0, kTopPadding, self.width, [self.class heightForReplyTableViewWithReplyArr:_replyArr width:self.width toComment:_toComment]);
    _replyTableView = [[SSThemedTableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _replyTableView.dataSource = self;
    _replyTableView.delegate = self;
    //    _replyTableView.backgroundColor = [UIColor clearColor];
    _replyTableView.scrollEnabled = NO;
    _replyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_replyTableView registerClass:[TTVCommentListReplyTableViewCell class]
            forCellReuseIdentifier:NSStringFromClass([TTVCommentListReplyTableViewCell class])];
    self.wrapper = [SSThemedView new];
    self.wrapper.frame = CGRectMake(0, 0, self.width, _replyTableView.height + kTopPadding*2);
    [self.wrapper addSubview:_replyTableView];
    [self addSubview:self.wrapper];
    self.height = self.wrapper.height;
    
    [self refreshReplyListBackgroundColors];
}

- (void)refreshReplyListBackgroundColors
{
    self.replyTableView.backgroundColor = tt_ttuisettingHelper_detailViewCommentReplyBackgroundColor();
    self.backgroundColor = tt_ttuisettingHelper_detailViewCommentReplyBackgroundColor();
}

- (void)refreshFramesWithWidth:(CGFloat)width
{
    self.width = width;
    CGRect rect = CGRectMake(0, kTopPadding, self.width, [self.class heightForReplyTableViewWithReplyArr:_replyArr width:self.width toComment:_toComment]);
    _replyTableView.frame = rect;
    _wrapper.frame = CGRectMake(0, 0, self.width, _replyTableView.height + kTopPadding*2);
    self.height = self.wrapper.height;
}

- (void)themeChanged:(NSNotification *)notification
{
    [self refreshReplyListBackgroundColors];
}

- (void)refreshReplyListWithComment:(id <TTVCommentModelProtocol>)commentModel
{
    _toComment = commentModel;
    _replyArr = [TTVCommentListReplyModel replyListForComment:commentModel];
     _replyTableView.frame = CGRectMake(0, kTopPadding, self.width, [self.class heightForReplyTableViewWithReplyArr:_replyArr width:self.width toComment:_toComment]);
    [_replyTableView reloadData];
       _replyTableView.superview.height = _replyTableView.height + kTopPadding*2;
       self.height = _replyTableView.height + kTopPadding*2;

}


#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.class shouldShowMoreReplyCellForReplyArr:_replyArr toComment:_toComment] ? _replyArr.count + 1 : _replyArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _replyArr.count) {
        return [TTVCommentListReplyTableViewCell heightForReplyModel:_replyArr[indexPath.row]
                                                          width:self.width - kHMargin*2] + kVMargin;
    }
    else {
        return [self.class showMoreReplyCellHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTVCommentListReplyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTVCommentListReplyTableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TTVCommentListReplyModel *model;
    if (indexPath.row < _replyArr.count) {
        model = _replyArr[indexPath.row];
    }
    else {
        NSString *moreReplyText = [NSString stringWithFormat:@"查看全部%@条回复", _toComment.replyCount];
        TTVCommentListReplyModel *moreReplyModel = [TTVCommentListReplyModel new];
        moreReplyModel.replyUserName = moreReplyText;
        moreReplyModel.commentID = _toComment.commentIDNum.stringValue;
        model = moreReplyModel;
        model.notReplyMsg = YES;
    }
    [cell refreshWithModel:model width:self.width];
    
    __weak typeof(self) wself = self;
    [cell handleUserClickActionWithBlock:^(TTVCommentListReplyModel *replyModel) {
        if (wself.replyUserBlock) {
            wself.replyUserBlock(replyModel);
        }
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!TTNetworkConnected()) {
        NSString *tip = @"连接失败，请稍后再试";
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:^(BOOL isUserDismiss) {
        }];
        return;
    }
    if (indexPath.row < _replyArr.count) {
        if (self.replyActionBlock) {
            self.replyActionBlock(_replyArr[indexPath.row]);
        }
    }
    else {
        if (self.replyActionBlock) {
            self.replyActionBlock(nil);
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Helper

+ (CGFloat)heightForListViewWithReplyArr:(NSArray<TTVCommentListReplyModel *> *)replyArr width:(CGFloat)width toComment:(id <TTVCommentModelProtocol>)toComment;
{
    replyArr = [TTVCommentListReplyModel replyListForComment:toComment];
    CGFloat tableViewHeight = [self heightForReplyTableViewWithReplyArr:replyArr width:width toComment:toComment];
    if ([self shouldShowMoreReplyCellForReplyArr:replyArr toComment:toComment]) {
        return tableViewHeight + (kTopPadding * 2);
    } else {
        return tableViewHeight + (kTopPadding * 2) - kVMargin; //查看全部不显示时. 为了保证视觉上tableview居中, 把多余的底部Margin移除 @zengruihuan
    }
}

+ (CGFloat)heightForReplyTableViewWithReplyArr:(NSArray<TTVCommentListReplyModel *> *)replyArr width:(CGFloat)width toComment:(id <TTVCommentModelProtocol>)toComment
{
    __block CGFloat height = 0;
    [replyArr enumerateObjectsUsingBlock:^(TTVCommentListReplyModel * _Nonnull replyModel, NSUInteger idx, BOOL * _Nonnull stop) {
        height += ([TTVCommentListReplyTableViewCell heightForReplyModel:replyModel width:width - kHMargin*2] + kVMargin);
    }];
    if ([self shouldShowMoreReplyCellForReplyArr:replyArr toComment:toComment]) {
        height += [self showMoreReplyCellHeight];
    }
    return height;
}

+ (CGFloat)showMoreReplyCellHeight
{
    return [TTVCommentListReplyTableViewCell tt_lineHeight] + 2.f;
}

+ (BOOL)shouldShowMoreReplyCellForReplyArr:(NSArray *)replyArr toComment:(id <TTVCommentModelProtocol>)toComment
{
    return toComment.replyCount.integerValue > replyArr.count;
}

@end
