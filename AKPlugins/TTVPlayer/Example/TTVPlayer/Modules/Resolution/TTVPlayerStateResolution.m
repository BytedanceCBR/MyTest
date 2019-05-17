//
//  TTVPlayerStateResolution.m
//  Article
//
//  Created by panxiang on 2018/8/23.
//

#import "TTVPlayerStateResolution.h"
#import "TTVPlayerStateResolutionPrivate.h"

@interface TTVPlayerStateResolution ()
@property (nonatomic ,copy)NSArray *titles;
@end
@implementation TTVPlayerStateResolution
- (instancetype)init
{
    self = [super init];
    if (self) {
        _titles = @[@"标清", @"高清", @"超清"];
    }
    return self;
}

- (NSString *)titleForResolution:(TTVideoEngineResolutionType)resolution {
    if (resolution < self.titles.count) {
        return self.titles[resolution];
    }
    return [self.titles lastObject];
}
@end


