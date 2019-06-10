//
//  BlockUsersListCell.m
//  Article
//
//  Created by Huaqing Luo on 9/3/15.
//
//

#import "BlockUsersListCell.h"
#import "TTIndicatorView.h"
#import "UIImage+TTThemeExtension.h"

@interface BlockUsersListCell () <TTBlockManagerDelegate>

@property (nonatomic, strong) NewFriendListCellUnit * listCellUnit;
@property (nonatomic, strong) TTBlockManager      * blockManager;

@end

@implementation BlockUsersListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.listCellUnit = [[NewFriendListCellUnit alloc] initWithFrame:CGRectMake(0, 0, width, self.height)];
        [_listCellUnit.relationButton addTarget:self action:@selector(relationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_listCellUnit];
        
        self.blockManager = [[TTBlockManager alloc] init];
        _blockManager.delegate = self;
    }
    
    return self;
}

- (void)refreshUI
{
    if (!_blockUser) {
        return;
    }
    
    [_listCellUnit refreshFrame];
}

- (void)setBlockUser:(ArticleFriendModel *)blockUser
{
    if (_blockUser == blockUser) {
        return;
    }
    
    _blockUser = blockUser;
    [_listCellUnit setFriendModel:_blockUser];
    [self refreshListCellUnitRelationButtonType];
}

#pragma mark - Actions

- (void)relationButtonClicked:(id)sender
{
    _listCellUnit.relationButtonType = FriendListCellUnitRelationButtonLoading;
    if (_blockUser.isBlocking) {
        [_blockManager unblockUser:_blockUser.ID];
        wrapperTrackEvent(@"blacklist", @"list_click_deblacklist");
    } else {
        [_blockManager blockUser:_blockUser.ID];
        wrapperTrackEvent(@"blacklist", @"list_click_blacklist");
    }
}

- (void)refreshListCellUnitRelationButtonType
{
    _listCellUnit.relationButtonType = _blockUser.isBlocking ? FriendListCellUnitRelationButtonCancelBlock : FriendListCellUnitRelationButtonBlock;
}

#pragma mark -- TTBlockManagerDelegate

- (void)blockUserManager:(TTBlockManager *)manager blocResult:(BOOL)success blockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip
{
    if (error) {
        NSString * failedDescription = @"拉黑失败";
        if (!isEmptyString(errorTip)) {
            failedDescription = errorTip;
        }
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:failedDescription indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        _blockUser.isBlocking = YES;
    }
    
    [self refreshListCellUnitRelationButtonType];
    
    if (_delegate && [_delegate respondsToSelector:@selector(blockUsersListCell:didBlockUser:)]) {
        [_delegate blockUsersListCell:self didBlockUser:YES];
    }
}

- (void)blockUserManager:(TTBlockManager *)manager unblockResult:(BOOL)success unblockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip
{
    if (error) {
        NSString * failedDescription = @"操作失败，请重试";
        if (!isEmptyString(errorTip)) {
            failedDescription = errorTip;
        }
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:failedDescription indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        _blockUser.isBlocking = NO;
    }
    
    [self refreshListCellUnitRelationButtonType];
    
    if (_delegate && [_delegate respondsToSelector:@selector(blockUsersListCell:didBlockUser:)]) {
        [_delegate blockUsersListCell:self didBlockUser:NO];
    }
}

@end
