//
//  FHIMShareUserListViewModel.m
//  ios_house_im
//
//  Created by leo on 2019/4/14.
//

#import "FHIMShareUserListViewModel.h"
#import "FHIMShareUserCell.h"
#import "IMManager.h"
#import "IChatService.h"
#import "FHChatUserInfoManager.h"
#import "FHChatUserInfo.h"
#import "RXCollection.h"
#import <BDWebImage/BDWebImage.h>
#import "FHUserTracker.h"
#import "TTAccountManager.h"
@interface FHIMShareUserListViewModel ()

@end

@implementation FHIMShareUserListViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.chatUsers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_chatUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHIMShareUserCell* cell = [tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    if ([_chatUsers count] > indexPath.row) {
        FHChatUserInfo* info = _chatUsers[indexPath.row];
        [cell.avator bd_setImageWithURL:[NSURL URLWithString:info.avatar]
                            placeholder:[UIImage imageNamed:@"chat_business_icon_c"]];
        cell.title.text = info.username;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_chatUsers count] > indexPath.row) {
        FHChatUserInfo* info = _chatUsers[indexPath.row];
        [self.delegate selectShareTarget:info atRow:indexPath.row];
    }
}

-(void)loadTargetUsers {
    NSString* currentUserId = [TTAccountManager currentUser].userID.stringValue;
    NSArray<IMConversation*>* cons = [[IMManager shareInstance].chatService allConversations];
    NSArray* users = [cons rx_mapWithBlock:^id(IMConversation* each) {
        if (each.type == IMConversationType1to1Chat) {
            __block FHChatUserInfo* result = nil;
            [each.someParticipants enumerateObjectsUsingBlock:^(BaseChatUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj.userId isEqualToString:currentUserId]) {
                    result = [[FHChatUserInfoManager shareInstance] getUserInfo:obj.userId];
                }
            }];
            return result;
        }
        return nil;
    }];
    self.chatUsers = [users mutableCopy];
}

@end
