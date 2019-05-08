//
//  TTMinePhotoCarouselEntry.m
//  Article
//
//  Created by chenjiesheng on 2018/3/7.
//

#import "AKMinePhotoCarouselEntry.h"

@implementation AKMinePhotoCarouselEntry


- (instancetype)initWithArray:(NSArray *)cellModelDicts
{
    self = [super init];
    if (self) {
        self.key = @"mine_photo_carousel";
        self.AKRequireLogin = YES;
        self.akTaskSwitch = YES;
        self.shouldBeDisplayed = YES;
        self.cellModels = [AKPhotoCarouselCellModel arrayOfModelsFromDictionaries:cellModelDicts error:nil];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.key = [aDecoder decodeObjectForKey:@"key"];
        self.cellModels = [aDecoder decodeObjectForKey:@"cell_model"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.cellModels forKey:@"cell_model"];
}
@end
