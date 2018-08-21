//
//  ArticleMomentGroup.m
//  Article
//
//  Created by Dianwei on 14-5-22.
//
//

#import "ArticleMomentGroupModel.h"
#import "NSDictionary+TTAdditions.h"

@interface ArticleMomentGroupModel()
@end

@implementation ArticleMomentGroupModel
@synthesize ID;
- (void)dealloc
{
    self.title = nil;
    self.thumbnailURLString = nil;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if(self)
    {
        self.ID = [dict tt_stringValueForKey:@"group_id_str"];
        if (isEmptyString(self.ID)) {
            if([dict objectForKey:@"group_id"])
            {
                self.ID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"group_id"]];
            }
        }
        
        self.title = [dict objectForKey:@"title"];
        if([dict objectForKey:@"item_type"])
        {
            self.groupType = [[dict objectForKey:@"item_type"] intValue];
        }
        else
        {
            self.groupType = ArticleMomentGroupNone;
        }
        
        self.thumbnailURLString = [dict objectForKey:@"thumb_url"];
        
        if ([dict objectForKey:@"media_type"])
        {
            self.mediaType = [[dict objectForKey:@"media_type"] intValue];
        }
        else
        {
            self.mediaType = NormalArticle;
        }
        
        if ([dict tt_stringValueForKey:@"open_url"]){
            
            self.openURL = [dict tt_stringValueForKey:@"open_url"];
        }
        
        if ([dict tt_stringValueForKey:@"item_id_str"]) {
            self.itemID = [dict tt_stringValueForKey:@"item_id_str"];
        }
        
        self.deleted = [dict tt_boolValueForKey:@"delete"];
        
        if ([dict tt_dictionaryValueForKey:@"user"]) {
            self.user = [[SSUserModel alloc] initWithDictionary:[dict tt_dictionaryValueForKey:@"user"]];
        }
        
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.groupType = [[aDecoder decodeObjectForKey:@"group_type"] intValue];
        self.thumbnailURLString = [aDecoder decodeObjectForKey:@"thumb_url"];
        self.mediaType = [[aDecoder decodeObjectForKey:@"media_type"] intValue];
     }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:@(_groupType) forKey:@"group_type"];
    [aCoder encodeObject:_thumbnailURLString forKey:@"thumb_url"];
    [aCoder encodeObject:@(_mediaType) forKey:@"media_type"];

}

- (void)updateWithDictionary:(NSDictionary*)dict
{
    if([dict objectForKey:@"title"])
    {
        self.title = [dict stringValueForKey:@"title"
                                defaultValue:nil];
    }
    
    if([dict objectForKey:@"item_type"])
    {
        self.groupType = [dict intValueForKey:@"item_type"
                                 defaultValue:ArticleMomentGroupNone];
    }
    
    if([dict objectForKey:@"thumb_url"])
    {
        self.thumbnailURLString = [dict stringValueForKey:@"thumb_url"
                                             defaultValue:nil];
    }
    
    if ([dict objectForKey:@"media_type"])
    {
        self.mediaType = [dict intValueForKey:@"media_type" defaultValue:NormalArticle];
    }
    
    if ([dict tt_stringValueForKey:@"item_id"]) {
        self.itemID = [dict tt_stringValueForKey:@"item_id"];
    }
}

@end
