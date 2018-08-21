//
//  TTFeedSaveRemoteOperation.m
//  Article
//
//  Created by fengyadong on 16/11/14.
//
//

#import "TTFeedSaveRemoteOperation.h"
#import "TTFeedContainerViewModel.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"

@import CoreSpotlight;
@interface TTFeedSaveRemoteOperation ()

@property (nonatomic, assign) uint64_t startTime;
@property (nonatomic, assign) uint64_t endTime;

@end

@implementation TTFeedSaveRemoteOperation

@synthesize startTime = _startTime;
@synthesize endTime = _endTime;

- (instancetype)initWithViewModel:(TTFeedContainerViewModel *)viewModel {
    if (self = [super initWithViewModel:viewModel]) {
    }
    return self;
}

- (void)asyncOperation {
    self.startTime = [NSObject currentUnixTime];

//    NSArray *objectsToBeSaved = self.viewModel.increaseItems;
//
//    if (objectsToBeSaved.count > 0) {
//            BOOL supportSpotlightSearch = [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0;
//            NSMutableArray * searchableItems = [NSMutableArray array];
//
//            [objectsToBeSaved enumerateObjectsUsingBlock:^(ExploreOrderedData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                [obj save];
//
//                //先对文章做 CoreSpotlight--nic
//                if (supportSpotlightSearch) {
//                    if ([obj.originalData isKindOfClass:[Article class]]) {
//                        CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:@"Article"];
//                        attributeSet.title = [[obj article] title];
//                        attributeSet.contentDescription = [[obj article] abstract];
//
//                        NSString *detailURL = [NSString stringWithFormat:@"sslocal://detail?groupid=%lld", obj.article.uniqueID];
//
//                        CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:detailURL domainIdentifier:@"Article" attributeSet:attributeSet];
//
//                        [searchableItems addObject:item];
//                    }
//                }
//            }];
//
//            if (supportSpotlightSearch) {
//                if (searchableItems.count > 0) {
//                    CSSearchableIndex * def = [CSSearchableIndex defaultSearchableIndex];
//                    //这里是添加index ，还要定期删除哦 deleteSearchableItemsWithDomainIdentifiers
//                    [def indexSearchableItems:searchableItems completionHandler:nil];
//                }
//            }
//    }

    self.endTime = [NSObject currentUnixTime];
    [self didFinishCurrentOperation];
}

@end
