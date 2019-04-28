//
//  ExploreCollectionBookCellModel.m
//  Article
//
//  Created by 王双华 on 16/9/23.
//
//

#import "ExploreCollectionBookCellModel.h"

@implementation ExploreCollectionBookCellModel

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        if (SSIsEmptyDictionary(dict)) {
            self = nil;
            return nil;
        }
        
        if ([[dict allKeys] containsObject:@"book_id"]) {
            self.bookID = @([dict longlongValueForKey:@"book_id" defaultValue:0]);
        }
        else {
            self.bookID = @(0);
        }
        
        NSDictionary *imageDict = nil;
        if ([[dict allKeys] containsObject:@"cover_image_info"]) {
            imageDict = [dict dictionaryValueForKey:@"cover_image_info" defalutValue:nil];
        }
        else if ([[dict allKeys] containsObject:@"cover_image_info_day"]){
            imageDict = [dict dictionaryValueForKey:@"cover_image_info_day" defalutValue:nil];
        }
        if ([imageDict isKindOfClass:[NSDictionary class]] && [imageDict count] > 0) {
            self.imageModel = [[TTImageInfosModel alloc] initWithDictionary:imageDict];
        }
        
        if ([[dict allKeys] containsObject:@"title"]) {
            self.title = [dict tt_stringValueForKey:@"title"];
        }
        else{
            self.title = @"";
        }
        
        if ([[dict allKeys] containsObject:@"desc"]) {
            self.desc = [dict tt_stringValueForKey:@"desc"];
        }
        else{
            self.desc = @"";
        }
        
        if ([[dict allKeys] containsObject:@"url"]) {
            self.schemaUrl = [dict tt_stringValueForKey:@"url"];
        }
        else{
            self.schemaUrl = @"";
        }
        
        NSDictionary *nightImageDict = nil;
        if ([[dict allKeys] containsObject:@"cover_image_info_night"]){
            nightImageDict = [dict dictionaryValueForKey:@"cover_image_info_night" defalutValue:nil];
        }
        if ([nightImageDict isKindOfClass:[NSDictionary class]] && [nightImageDict count] > 0) {
            self.nightImageModel = [[TTImageInfosModel alloc] initWithDictionary:nightImageDict];
        }
        else{
            self.nightImageModel = nil;
        }
        
    }
    
    return self;
}

@end

