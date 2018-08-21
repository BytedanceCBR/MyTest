//
//  ExploreDislikeWord.h
//  Article
//
//  Created by Chen Hong on 14/11/23.
//
//

#import <Foundation/Foundation.h>

@interface TTFeedDislikeWord : NSObject

@property(nonatomic,copy)NSString *ID;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)BOOL isSelected;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
