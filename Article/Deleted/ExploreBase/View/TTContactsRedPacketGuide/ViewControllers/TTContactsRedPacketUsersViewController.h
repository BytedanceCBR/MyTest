//
//  TTContactsRedPacketUsersViewController.h
//  Article
//  通讯录红包选择关注用户
//
//  Created by Jiyee Sheng on 8/8/17.
//
//


#import "SSViewControllerBase.h"

@protocol TTContactsRedPacketUsersDelegate <NSObject>

- (void)didUpdateContactUsers:(NSArray *)contactUsers;

@end


@interface TTContactsRedPacketUsersViewController : SSViewControllerBase

@property (nonatomic, weak) id <TTContactsRedPacketUsersDelegate> delegate;

- (instancetype)initWithContactUsers:(NSArray *)contactUsers;

@end
