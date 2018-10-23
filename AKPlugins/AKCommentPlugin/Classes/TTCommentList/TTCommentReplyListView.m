//
//  TTCommentReplyListView.m
//  Article
//
//  Created by 冯靖君 on 15/12/3.
//
//

#import "TTCommentReplyListView.h"
#import "TTCommentReplyModel.h"
#import <TTRoute/TTRoute.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/UIViewAdditions.h>
#import "NetworkUtilities.h"


#define kTopPadding [TTDeviceUIUtils tt_newPadding:12.f]

@interface TTCommentReplyListView () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) SSThemedView *wrapper;
@property(nonatomic, strong) SSThemedTableView *replyTableView;
@property(nonatomic, strong) id<TTCommentModelProtocol> toComment;
@property(nonatomic, strong) NSArray<TTCommentReplyModel *> *replyArr;
@property(nonatomic, copy) TTCommentReplyActionBlock replyActionBlock;
@property(nonatomic, copy) TTCommentReplyActionBlock replyUserBlock;

@end

@implementation TTCommentReplyListView

- (instancetype)initWithWidth:(CGFloat)width toComment:(id<TTCommentModelProtocol>)toComment
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        _toComment = toComment;
        _replyArr = toComment.replyModelArr;
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

- (void)didClickReplyToMakeAction:(TTCommentReplyActionBlock)block
{
    if (block) {
        self.replyActionBlock = block;
    }
}

- (void)didClickReplyToViewUser:(TTCommentReplyActionBlock)block
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
    _replyTableView.scrollEnabled = NO;
    _replyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_replyTableView registerClass:[TTCommentReplyTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TTCommentReplyTableViewCell class])];
    self.wrapper = [SSThemedView new];
    self.wrapper.frame = CGRectMake(0, 0, self.width, _replyTableView.height + kTopPadding*2);
    [self.wrapper addSubview:_replyTableView];
    [self addSubview:self.wrapper];
    self.height = self.wrapper.height;
    
    [self refreshReplyListBackgroundColors];
}

- (void)refreshReplyListBackgroundColors
{
    self.replyTableView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
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

- (void)refreshReplyListWithComment:(id<TTCommentModelProtocol>)commentModel
{
    _toComment = commentModel;
    _replyArr = commentModel.replyModelArr;
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
        return [TTCommentReplyTableViewCell heightForReplyModel:_replyArr[indexPath.row]
                                                          width:self.width - kHMargin*2] + kVMargin;
    }
    else {
        return [self.class showMoreReplyCellHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTCommentReplyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TTCommentReplyTableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TTCommentReplyModel *model;
    if (indexPath.row < _replyArr.count) {
        model = _replyArr[indexPath.row];
    }
    else {
        NSString *moreReplyText = [NSString stringWithFormat:@"查看全部%lld条回复", [_toComment.replyCount longLongValue]];
        TTCommentReplyModel *moreReplyModel = [TTCommentReplyModel replyModelWithDict:@{@"user_name":moreReplyText} forCommentID:_toComment.commentID.stringValue];
        moreReplyModel.notReplyMsg = YES;
        model = moreReplyModel;
    }
    [cell refreshWithModel:model width:self.width];
    
    __weak typeof(self) wself = self;
    [cell handleUserClickActionWithBlock:^(TTCommentReplyModel *replyModel) {
        if (wself.replyUserBlock) {
            wself.replyUserBlock(replyModel);
        }
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

+ (CGFloat)heightForListViewWithReplyArr:(NSArray<TTCommentReplyModel *> *)replyArr width:(CGFloat)width toComment:(id<TTCommentModelProtocol>)toComment
{
    CGFloat tableViewHeight = [self heightForReplyTableViewWithReplyArr:replyArr width:width toComment:toComment];
    if ([self shouldShowMoreReplyCellForReplyArr:replyArr toComment:toComment]) {
        return tableViewHeight + (kTopPadding * 2);
    } else {
        return tableViewHeight + (kTopPadding * 2) - kVMargin; //查看全部不显示时. 为了保证视觉上tableview居中, 把多余的底部Margin移除 @zengruihuan
    }
}

+ (CGFloat)heightForReplyTableViewWithReplyArr:(NSArray<TTCommentReplyModel *> *)replyArr width:(CGFloat)width toComment:(id<TTCommentModelProtocol>)toComment
{
    __block CGFloat height = 0;
    [replyArr enumerateObjectsUsingBlock:^(TTCommentReplyModel * _Nonnull replyModel, NSUInteger idx, BOOL * _Nonnull stop) {
        height += ([TTCommentReplyTableViewCell heightForReplyModel:replyModel width:width - kHMargin*2] + kVMargin);
    }];
    if ([self shouldShowMoreReplyCellForReplyArr:replyArr toComment:toComment]) {
        height += [self showMoreReplyCellHeight];
    }
    return height;
}

+ (CGFloat)showMoreReplyCellHeight
{
    return [TTCommentReplyTableViewCell tt_lineHeight] + 2.f;
}

+ (BOOL)shouldShowMoreReplyCellForReplyArr:(NSArray *)replyArr toComment:(id<TTCommentModelProtocol>)toComment
{
    return [toComment.replyCount longLongValue] > replyArr.count;
}

@end
