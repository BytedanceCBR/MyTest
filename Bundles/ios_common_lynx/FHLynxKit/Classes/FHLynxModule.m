//
//  FHLynxModule.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/21.
//

#import "FHLynxModule.h"

@implementation FHLynxModule

+ (NSDictionary<NSString *, NSString *> *)methodLookup {
  return @{
    @"testCore" : NSStringFromSelector(@selector(testCore)),
  };
}

+ (NSString *)name {
  return @"CoreModule";
}

- (void)testCore {
  NSLog(@"testCore");
}

@end
