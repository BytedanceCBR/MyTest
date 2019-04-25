//
//  EssayContentManager.h
//  Article
//
//  Created by Hua Cao on 13-10-22.
//
//

#import <Foundation/Foundation.h>


@interface EssayContentManager : NSObject

- (void)tryLoadContentWithEssayGroupID:(NSString *)essayGroupID;

@property (nonatomic, copy) void (^didFinishCallback)(NSDictionary * response);
@property (nonatomic, copy) void (^didFailCallback)(NSError * error);

@end
