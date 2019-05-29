//
//  FHIMShareUserListViewModel.h
//  ios_house_im
//
//  Created by leo on 2019/4/14.
//

#import <Foundation/Foundation.h>
@class FHChatUserInfo;
NS_ASSUME_NONNULL_BEGIN

@protocol FHIMShareUserListViewModelDelegate <NSObject>

-(void)selectShareTarget:(FHChatUserInfo*)target atRow:(NSUInteger)row;

@end

@interface FHIMShareUserListViewModel : NSObject<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray<FHChatUserInfo*>* chatUsers;
@property (nonatomic, weak) id<FHIMShareUserListViewModelDelegate> delegate;
-(void)loadTargetUsers;
@end

NS_ASSUME_NONNULL_END
