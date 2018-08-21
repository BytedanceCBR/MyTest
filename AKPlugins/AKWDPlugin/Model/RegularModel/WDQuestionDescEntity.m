//
//  WDQuestionDescEntity.m
//  Article
//
//  Created by 延晋 张 on 2016/10/24.
//
//

#import "WDQuestionDescEntity.h"
#import "WDDataBaseManager.h"
#import "WDDefines.h"

@implementation WDQuestionDescEntity

#pragma mark -- self
- (instancetype)initWithWDQuestionDescStructModel:(WDQuestionDescStructModel *)model
{
    self = [super init];
    if (self) {
        self.text = [model.text stringByTrimmingCharactersInSet:
                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableArray *large = [[NSMutableArray alloc] init];
        for (WDImageUrlStructModel *image in model.large_image_list) {
            @try {
                TTImageInfosModel *infosModel = [[TTImageInfosModel alloc] initWithDictionary:[image toDictionary]];
                [large addObject:infosModel];
            }
            @catch (NSException *exception) {
                // nothing to do...
            }
        }
        self.largeImageList = [NSArray arrayWithArray:large];
        
        NSMutableArray *thumb = [[NSMutableArray alloc] init];
        for (WDImageUrlStructModel *image in model.thumb_image_list) {
            @try {
                TTImageInfosModel *infosModel = [[TTImageInfosModel alloc] initWithDictionary:[image toDictionary]];
                [thumb addObject:infosModel];
            }
            @catch (NSException *exception) {
                // nothing to do...
            }
        }
        self.thumbImageList = [NSArray arrayWithArray:thumb];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    self.text = [[dictionary tt_stringValueForKey:@"text"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableArray *thumbImageArrayList = [dictionary tt_objectForKey:@"thumb_image_list"];
    NSMutableArray *largeImageArrayList = [dictionary tt_objectForKey:@"large_image_list"];
    
    NSMutableArray *large = [[NSMutableArray alloc] init];
    for (NSDictionary *image in largeImageArrayList) {
        TTImageInfosModel *infosModel = [[TTImageInfosModel alloc] initWithDictionary:image];
        [large addObject:infosModel];
    }
    self.largeImageList = [NSArray arrayWithArray:large];
    
    NSMutableArray *thumb = [[NSMutableArray alloc] init];
    for (NSDictionary *image in thumbImageArrayList) {
        TTImageInfosModel *infosModel = [[TTImageInfosModel alloc] initWithDictionary:image];
        [thumb addObject:infosModel];
    }
    self.thumbImageList = [NSArray arrayWithArray:thumb];
}

@end
