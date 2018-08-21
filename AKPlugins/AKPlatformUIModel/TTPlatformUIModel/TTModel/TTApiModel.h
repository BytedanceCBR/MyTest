#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

 

#define kIsCheckProperties NO

@interface TTApi : JSONModel<NSCoding>

@end

@protocol TTForumModel <NSObject>

@end

@interface ForumFeed : TTApi
@property (assign, nonatomic) NSInteger followed_count;
@property (assign, nonatomic) NSInteger followed_has_more;
@property (strong, nonatomic) NSArray<TTForumModel> * followed;
@property (strong, nonatomic) NSArray<TTForumModel> * interested;

@end
