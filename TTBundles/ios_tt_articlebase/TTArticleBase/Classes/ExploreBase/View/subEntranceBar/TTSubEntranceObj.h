//
//  TTSubEntranceObj.h
//  Article
//
//  Created by Chen Hong on 15/6/23.
//
//

#import <Foundation/Foundation.h>

@interface TTSubEntranceObj : NSObject

@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *openUrl;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
