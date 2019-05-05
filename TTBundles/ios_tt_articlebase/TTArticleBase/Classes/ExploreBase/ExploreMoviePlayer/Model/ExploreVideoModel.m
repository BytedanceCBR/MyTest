//
//  ExploreLeTVVideoModel.m
//  Article
//
//  Created by Zhang Leonardo on 15-3-5.
//
//

#import "ExploreVideoModel.h"


@implementation ExploreVideoModel

- (NSArray *)allURLWithDefinitionType:(ExploreVideoDefinitionType)type
{
    if (self.videoInfo) {
        return [self.videoInfo allURLWithDefinition:type];
    }
    
    if (self.liveInfo) {
        return [self.liveInfo allURL];
    }
    return nil;
}

- (BOOL)isPasterADModel
{
    return self.adInfo != nil;
}

@end
