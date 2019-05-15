//
//  SSTrendsModel.m
//  Article
//
//  Created by Dianwei on 14-5-21.
//
//
#import "ArticleMomentModel.h"
#import "ArticleMomentCommentModel.h"
#import "SSUserModel.h"
#import "ArticleMomentGroupModel.h"
#import <TTAccountBusiness.h>



@interface ArticleMomentModel()
@property(nonatomic, retain, readwrite)NSMutableOrderedSet *comments;
@property(nonatomic, retain)NSDictionary * imageTypesDict;
@end
@implementation ArticleMomentModel
+ (NSArray*)momentsWithArray:(NSArray*)array
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];
    for(NSDictionary *data in array)
    {
        ArticleMomentModel *model = [[ArticleMomentModel alloc] initWithDictionary:data];
        [result addObject:model];
    }
    
    return result;
}
- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.diggUsers = [NSMutableOrderedSet orderedSet];
        self.comments = [NSMutableOrderedSet orderedSet];
    }
    
    return self;
}
- (void) dealloc {
    self.largeImgeDicts = nil;
    self.thumbImgeDicts = nil;
    self.content = nil;
    self.diggUsers = nil;
    self.comments = nil;
    self.user = nil;
    self.ID = nil;
    self.comments =nil;
    self.actionDescription = nil;
    self.deviceModelString = nil;
    self.reason = nil;
    self.group = nil;
    self.originItem = nil;
    self.forwardNum = nil;
    self.talkItem = nil;
    self.imageTypesDict = nil;
    
    self.name = nil;
    self.sname = nil;
    self.gid = nil;
    self.sign = nil;
    self.url = nil;
    self.avatar = nil;
    self.distance = nil;
}
- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if(self)
    {
        if ([dict objectForKey:@"item_type"]) {
            self.itemType = [[dict objectForKey:@"item_type"] unsignedIntegerValue];
        } else {
            self.itemType = MomentItemTypeNone;
        }
        
        if (self.itemType == MomentItemTypeIESVideo) {// IES video取id_str作为ID
            self.ID = [dict tt_stringValueForKey:@"id_str"];
        }
        else{
            self.ID = [dict tt_stringValueForKey:@"group_id_str"];
        }
        if (isEmptyString(self.ID)) {
            self.ID = [dict tt_stringValueForKey:@"id"];
        }
        
        self.threadID = [dict tt_stringValueForKey:@"thread_id_str"];
        if (isEmptyString(self.threadID)) {
            self.threadID = [dict tt_stringValueForKey:@"thread_id"];
        }
        
        self.commentID = [dict tt_stringValueForKey:@"comment_id"];
        
        self.threadStatus = [dict tt_integerValueForKey:@"status"];
        
        self.content = [dict objectForKey:@"content"] ? [NSString stringWithFormat:@"%@", [dict objectForKey:@"content"]] : nil;
        self.contentUnescape = [dict tt_stringValueForKey:@"content_unescape"];
        self.contentRichSpan = [dict tt_stringValueForKey:@"content_rich_span"];
        self.cursor = [[dict objectForKey:@"cursor"] doubleValue];
        self.createTime = [[dict objectForKey:@"create_time"] doubleValue];
        
        if([dict objectForKey:@"user"])
        {
            self.user = [[SSUserModel alloc] initWithDictionary:[dict objectForKey:@"user"]];
        }
        
        if([dict objectForKey:@"digg_list"])
        {
            self.diggUsers = [NSMutableOrderedSet orderedSetWithArray:[SSUserModel usersWithArray:[dict objectForKey:@"digg_list"]]];
        }
        else
        {
            self.diggUsers = [NSMutableOrderedSet orderedSet];
        }
        
        self.digged = [[dict objectForKey:@"user_digg"] boolValue];
        self.diggsCount = [[dict objectForKey:@"digg_count"] intValue];
        if([dict objectForKey:@"digg_limit"])
        {
            self.diggLimit = [[dict objectForKey:@"digg_limit"] intValue];
            if (_diggLimit == 0) {
                _diggLimit = kMomentModelDiggUserLimitZero;
            }
        }
        else {
            self.diggLimit = kMomentModelDiggUserLimitMax;
        }
        
        self.commentsCount = [[dict objectForKey:@"comment_count"] intValue];
        
        self.visibleCommentsCount = [[dict objectForKey:@"comment_visible_count"] intValue];
        
        self.shareURL = dict[@"share_url"];
        
        if([dict objectForKey:@"comments"])
        {
            self.comments = [NSMutableOrderedSet orderedSetWithArray:[ArticleMomentCommentModel commentsWithArray:[dict objectForKey:@"comments"]]];
        }
        else
        {
            self.comments = [NSMutableOrderedSet orderedSet];
        }
        
        if([dict objectForKey:@"group"])
        {
            self.group = [[ArticleMomentGroupModel alloc] initWithDictionary:[dict objectForKey:@"group"]];
        }
        
        if([dict objectForKey:@"flags"])
        {
            self.flags = [[dict objectForKey:@"flags"] intValue];
        }
        else
        {
            self.flags = MomentFlagNone;
        }
        
        self.deviceType = [[dict objectForKey:@"device_type"] intValue];
        
        self.actionDescription = [dict objectForKey:@"action_desc"];
        self.type = [[dict objectForKey:@"type"] intValue];
        self.modifyTime = [[dict objectForKey:@"modify_time"] doubleValue];
        self.isDeleted = [[dict objectForKey:@"delete"] boolValue];
        
        if([dict objectForKey:@"device_model"])
        {
            self.deviceModelString = [dict objectForKey:@"device_model"];
        }
        
        if([dict objectForKey:@"reason"])
        {
            self.reason = dict[@"reason"];
        }
        
        if ([dict objectForKey:@"cell_type"]) {
            self.cellType = [[dict objectForKey:@"cell_type"] unsignedIntegerValue];
        } else {
            self.cellType = MomentListCellTypeNone;
        }
        
        self.forwardNum = @([[dict objectForKey:@"forward_num"] longLongValue]);
        
        self.contentIncomplete = [[dict objectForKey:@"content_incomplete"] boolValue];
        
        self.talkItem = [dict objectForKey:@"talk_item"];
        self.isAdmin = [[dict objectForKey:@"is_admin"] boolValue];
        self.largeImgeDicts = [dict objectForKey:@"large_image_list"];
        self.thumbImgeDicts = [dict objectForKey:@"thumb_image_list"];
        if ([dict tt_dictionaryValueForKey:@"origin_item"]) {
            self.originItem = [[ArticleMomentModel alloc] initWithDictionary:[dict tt_dictionaryValueForKey:@"origin_item"]];
        }
        if ([dict tt_dictionaryValueForKey:@"origin_thread"]) {
            self.originThread = [[ArticleMomentModel alloc] initWithDictionary:[dict tt_dictionaryValueForKey:@"origin_thread"]];
        }
        if ([dict tt_dictionaryValueForKey:@"origin_group"]) {
            self.originGroup = [[ArticleMomentGroupModel alloc] initWithDictionary:[dict tt_dictionaryValueForKey:@"origin_group"]];
        }
                
        if ([[dict objectForKey:@"image_type"] isKindOfClass:[NSDictionary class]]) {
            self.imageTypesDict = [dict objectForKey:@"image_type"];
        }
        if (dict[@"reply_to_comment"]) {
            self.qutoedCommentModel = [[TTQutoedCommentModel alloc] initWithDictionary:dict[@"reply_to_comment"]];
        }
        if ([dict objectForKey:@"show_origin"]) {
            self.showOrigin = @([dict tt_boolValueForKey:@"show_origin"]);
        }
        if ([dict objectForKey:@"show_tips"]) {
            self.showTips = [dict tt_stringValueForKey:@"show_tips"];
        }
        
        [self updateMomoDictionary:dict];
    }
    
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.createTime = [[aDecoder decodeObjectForKey:@"create_time"] doubleValue];
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.cursor = [[aDecoder decodeObjectForKey:@"cursor"] doubleValue];
        self.user = [aDecoder decodeObjectForKey:@"user"];
        self.diggUsers = [NSMutableOrderedSet orderedSet];
        NSMutableOrderedSet *usersSet = [aDecoder decodeObjectForKey:@"digg_users"];
        if ([usersSet count] > 0) {
            [_diggUsers addObjectsFromArray:[usersSet array]];
        }
        self.digged = [[aDecoder decodeObjectForKey:@"digged"] boolValue];
        self.diggsCount = [[aDecoder decodeObjectForKey:@"digg_count"] intValue];
        self.diggLimit = [[aDecoder decodeObjectForKey:@"digg_limit"] intValue];
        self.commentsCount = [[aDecoder decodeObjectForKey:@"comment_count"] intValue];
        self.shareURL = [aDecoder decodeObjectForKey:@"share_url"];
        self.comments = [NSMutableOrderedSet orderedSet];
        NSMutableOrderedSet *commentsSet = [aDecoder decodeObjectForKey:@"comments"];
        if ([commentsSet count] > 0) {
            [self.comments addObjectsFromArray:[commentsSet array]];
        }
        self.visibleCommentsCount = [[aDecoder decodeObjectForKey:@"comment_visible_count"] intValue];
        
        self.group = [aDecoder decodeObjectForKey:@"group"];
        self.flags = [[aDecoder decodeObjectForKey:@"flags"] intValue];
        self.actionDescription = [aDecoder decodeObjectForKey:@"action_desc"];
        self.type = [[aDecoder decodeObjectForKey:@"type"] intValue];
        self.modifyTime = [[aDecoder decodeObjectForKey:@"modify_time"] doubleValue];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.deviceType = [[aDecoder decodeObjectForKey:@"device_type"] intValue];
        self.deviceModelString = [aDecoder decodeObjectForKey:@"device_model"];
        self.isDeleted = [[aDecoder decodeObjectForKey:@"delete"] boolValue];
        self.reason = [aDecoder decodeObjectForKey:@"reason"];
        self.cellType = [[aDecoder decodeObjectForKey:@"cell_type"] unsignedIntegerValue];
        
        self.itemType = [[aDecoder decodeObjectForKey:@"item_type"] unsignedIntegerValue];
        self.originItem = [aDecoder decodeObjectForKey:@"origin_item"];
        self.forwardNum = [aDecoder decodeObjectForKey:@"forward_num"];
        self.contentIncomplete = [[aDecoder decodeObjectForKey:@"content_incomplete"] boolValue];
        self.talkItem = [aDecoder decodeObjectForKey:@"talk_item"];
        self.isAdmin = [[aDecoder decodeObjectForKey:@"is_admin"] boolValue];
        self.largeImgeDicts = [aDecoder decodeObjectForKey:@"large_image_list"];
        self.thumbImgeDicts = [aDecoder decodeObjectForKey:@"thumb_image_list"];
        
        if ([[aDecoder decodeObjectForKey:@"image_type"] isKindOfClass:[NSDictionary class]]) {
            self.imageTypesDict = [aDecoder decodeObjectForKey:@"image_type"];
        }
        
        self.gid = [aDecoder decodeObjectForKey:@"gid"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        self.distance = [aDecoder decodeObjectForKey:@"distance"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.sign = [aDecoder decodeObjectForKey:@"sign"];
        self.sname = [aDecoder decodeObjectForKey:@"sname"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        
    }
    
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(_createTime) forKey:@"create_time"];
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:@(_cursor) forKey:@"cursor"];
    [aCoder encodeObject:_user forKey:@"user"];
    [aCoder encodeObject:_diggUsers forKey:@"digg_users"];
    [aCoder encodeObject:@(_digged) forKey:@"digged"];
    [aCoder encodeObject:@(_diggsCount) forKey:@"digg_count"];
    [aCoder encodeObject:@(_diggLimit) forKey:@"digg_limit"];
    [aCoder encodeObject:@(_commentsCount) forKey:@"comment_count"];
    [aCoder encodeObject:_shareURL forKey:@"share_url"];
    [aCoder encodeObject:_comments forKey:@"comments"];
    [aCoder encodeObject:_group forKey:@"group"];
    [aCoder encodeObject:@(_flags) forKey:@"flags"];
    [aCoder encodeObject:_actionDescription forKey:@"action_desc"];
    [aCoder encodeObject:@(_type) forKey:@"type"];
    [aCoder encodeObject:@(_modifyTime) forKey:@"modify_time"];
    [aCoder encodeObject:_content forKey:@"content"];
    [aCoder encodeObject:@(_deviceType) forKey:@"device_type"];
    [aCoder encodeObject:_deviceModelString forKey:@"device_model"];
    [aCoder encodeObject:@(_isDeleted) forKey:@"delete"];
    [aCoder encodeObject:_reason forKey:@"reason"];
    [aCoder encodeObject:@(_cellType) forKey:@"cell_type"];
    [aCoder encodeObject:@(_itemType) forKey:@"item_type"];
    [aCoder encodeObject:_originItem forKey:@"origin_item"];
    [aCoder encodeObject:_forwardNum forKey:@"forward_num"];
    [aCoder encodeObject:@(_contentIncomplete) forKey:@"content_incomplete"];
    [aCoder encodeObject:_talkItem forKey:@"talk_item"];
    [aCoder encodeObject:@(_isAdmin) forKey:@"is_admin"];
    [aCoder encodeObject:_largeImgeDicts forKey:@"large_image_list"];
    [aCoder encodeObject:_thumbImgeDicts forKey:@"thumb_image_list"];
    [aCoder encodeObject:@(_visibleCommentsCount) forKey:@"comment_visible_count"];
    [aCoder encodeObject:_imageTypesDict forKey:@"image_type"];
    
    [aCoder encodeObject:self.gid forKey:@"gid"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:self.distance forKey:@"distance"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.sign forKey:@"sign"];
    
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.sname forKey:@"sname"];
}
- (void)updateWithDictionary:(NSDictionary*)dict
{
    if ([dict objectForKey:@"create_time"]) {
        self.createTime = [[dict objectForKey:@"create_time"] doubleValue];
    }
    
    if([dict objectForKey:@"content"])
    {
        self.content = [NSString stringWithFormat:@"%@", [dict objectForKey:@"content"]];
    }
    
    if([dict objectForKey:@"cursor"])
    {
        self.cursor = [[dict objectForKey:@"cursor"] doubleValue];
    }
    
    if([dict objectForKey:@"user"])
    {
        self.user = [[SSUserModel alloc] initWithDictionary:[dict objectForKey:@"user"]];
    }
    
    if([dict objectForKey:@"digg_list"])
    {
        [_diggUsers addObjectsFromArray:[SSUserModel usersWithArray:[dict objectForKey:@"digg_list"]]];
    }
    
    if([dict objectForKey:@"user_digg"])
    {
        if (!self.digged) { // 保护
            self.digged = [[dict objectForKey:@"user_digg"] boolValue];
        }
    }
    
    if([dict objectForKey:@"digg_count"])
    {
        if (self.diggsCount < [[dict objectForKey:@"digg_count"] intValue]) { // 保护
            self.diggsCount = [[dict objectForKey:@"digg_count"] intValue];
        }
    }
    
    if([dict objectForKey:@"digg_limit"])
    {
        self.diggLimit = [[dict objectForKey:@"digg_limit"] intValue];
        if (_diggLimit == 0) {
            _diggLimit = kMomentModelDiggUserLimitZero;
        }
    }
    if([dict objectForKey:@"comment_count"])
    {
        self.commentsCount = [[dict objectForKey:@"comment_count"] intValue];
    }
    
    if (dict[@"share_url"]) {
        self.shareURL = dict[@"share_url"];
    }
    
    if([dict objectForKey:@"comments"])
    {
        NSArray *commentsArray = [dict tt_arrayValueForKey:@"comments"];
        if (!SSIsEmptyArray(commentsArray)) {
            [_comments removeAllObjects];
            [_comments addObjectsFromArray:[ArticleMomentCommentModel commentsWithArray:commentsArray]];
        }
    }
    
    if([dict objectForKey:@"group"])
    {
        [self.group updateWithDictionary:[dict objectForKey:@"group"]];
    }
    
    
    if([dict objectForKey:@"flags"])
    {
        self.flags = [[dict objectForKey:@"flags"] intValue];
    }
    
    if([dict objectForKey:@"action_desc"])
    {
        self.actionDescription = [dict objectForKey:@"action_desc"];
    }
    
    if([dict objectForKey:@"type"])
    {
        self.type = [[dict objectForKey:@"type"] intValue];
    }
    
    if([dict objectForKey:@"modify_time"])
    {
        self.modifyTime = [[dict objectForKey:@"modify_time"] doubleValue];
    }
    
    if([dict objectForKey:@"device_type"])
    {
        self.deviceType = [[dict objectForKey:@"device_type"] intValue];
    }
    
    if([dict objectForKey:@"device_model"])
    {
        self.deviceModelString = [dict objectForKey:@"device_model"];
    }
    
    if([dict objectForKey:@"delete"])
    {
        self.isDeleted = [[dict objectForKey:@"delete"] boolValue];
    }
    
    if([dict objectForKey:@"reason"])
    {
        self.reason = dict[@"reason"];
    }
    if([dict objectForKey:@"cell_type"])
    {
        self.cellType = [dict[@"cell_type"] unsignedIntegerValue];
    }
    
    if ([dict objectForKey:@"item_type"]) {
        self.itemType = [[dict objectForKey:@"item_type"] unsignedIntegerValue];
    }
    if([dict objectForKey:@"forward_num"]) {
        self.forwardNum = @([[dict objectForKey:@"forward_num"] longLongValue]);
    }
    if([dict objectForKey:@"content_incomplete"]) {
        self.contentIncomplete = [[dict objectForKey:@"content_incomplete"] boolValue];
    }
    if ([dict objectForKey:@"talk_item"]) {
        self.talkItem = [dict objectForKey:@"talk_item"];
    }
    if ([dict objectForKey:@"is_admin"]) {
        self.isAdmin = [[dict objectForKey:@"is_admin"] boolValue];
    }
    if ([dict objectForKey:@"thumb_image_list"]) {
        self.thumbImgeDicts = [dict objectForKey:@"thumb_image_list"];
    }
    if ([dict objectForKey:@"large_image_list"]) {
        self.largeImgeDicts = [dict objectForKey:@"large_image_list"];
    }
    
    if ([[dict objectForKey:@"image_type"] isKindOfClass:[NSDictionary class]]) {
        self.imageTypesDict = [dict objectForKey:@"image_type"];
    }
    if (dict[@"reply_to_comment"]) {
        self.qutoedCommentModel = [[TTQutoedCommentModel alloc] initWithDictionary:dict[@"reply_to_comment"]];
    }
    if ([dict objectForKey:@"show_origin"]) {
        self.showOrigin = @([dict tt_boolValueForKey:@"show_origin"]);
    }
    if ([dict objectForKey:@"show_tips"]) {
        self.showTips = [dict tt_stringValueForKey:@"show_tips"];
    }
    [self updateMomoDictionary:dict];
}
- (void)insertComment:(ArticleMomentCommentModel*)comment
{
    if (!comment) {
        return;
    }
    
    if(![_comments containsObject:comment])
    {
        NSInteger idx = _comments.count;
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"comments"];
        if ([_comments count] > 0) {
            [_comments insertObject:comment atIndex:0];
        }
        else {
            [_comments addObject:comment];
        }
        ++ self.commentsCount;
        ++ self.visibleCommentsCount;
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"comments"];
    }
}
- (void)deleteComment:(ArticleMomentCommentModel*)comment {
    if (!comment) {
        return;
    }
    
    if ([_comments containsObject:comment])
    {
        NSInteger idx = [_comments indexOfObject:comment];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"comments"];
        [_comments removeObject:comment];
        -- self.commentsCount;
        -- self.visibleCommentsCount;
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:@"comments"];
    }
}
- (void)insertDiggUser:(SSUserBaseModel*)user
{
    if (user == nil) {
        return;
    }
    if(![_diggUsers containsObject:user])
    {
        NSInteger idx = _diggUsers.count;
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"diggUsers"];
        if ([_diggUsers count] > 0) {
            [_diggUsers insertObject:user atIndex:0];
        }
        else {
            [_diggUsers addObject:user];
        }
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:@"diggUsers"];
    }
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"cursor %f, content %@", self.cursor, self.content];
}
- (NSString *)forumName
{
    return [_talkItem objectForKey:@"forum_name"];
}
- (long long)forumID
{
    return [[_talkItem objectForKey:@"forum_id"] longLongValue];
}
- (NSString *)openURL
{
    return [_talkItem tt_stringValueForKey:@"open_url"];
}
- (NSArray *)thumbImageList
{
    if ([_thumbImgeDicts count] == 0) {
        return nil;
    }
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary * dict in _thumbImgeDicts) {
        TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:dict];
        if (model) {
            //            测试各种情况下UI的显示有无问题
            //            if (result.count < 1) {
            if ([_imageTypesDict objectForKey:model.URI]) {
                model.imageFileType = (TTImageFileType)[[_imageTypesDict objectForKey:model.URI] intValue];
            }
            [result addObject:model];
            //            }
        }
    }
    return result;
}
- (NSArray *)largeImageList
{
    if ([_largeImgeDicts count] == 0) {
        return nil;
    }
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary * dict in _largeImgeDicts) {
        TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:dict];
        if (model) {
            [result addObject:model];
        }
    }
    return result;
}
/*
 - (NSDictionary *)imageTypes
 {
 return self.imageTypesDict;
 }*/
- (void)deleteModelContent
{
    self.content = kArticleMomentModelContentDeletedTip;
    self.talkItem = nil;
    self.largeImgeDicts = nil;
    self.thumbImgeDicts = nil;
    self.diggUsers = nil;
    self.comments = nil;
    self.group = nil;
}
- (void)updateMomoDictionary:(NSDictionary *)dictionary {
    if (self.cellType == MomentListCellTypeMomo) {
        self.sname = [dictionary tt_stringValueForKey:@"sname"];
        self.name = [dictionary tt_stringValueForKey:@"name"];
        self.distance = [dictionary tt_stringValueForKey:@"distance"];
        self.url = [dictionary tt_stringValueForKey:@"url"];
        if ([dictionary valueForKey:@"gid"]) {
            self.gid = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"gid"]];
        }
        self.sign = [dictionary tt_stringValueForKey:@"sign"];
        self.avatar = [dictionary tt_stringValueForKey:@"avatar"];
    } else {
        self.sname = nil;
        self.name = nil;
        self.distance = nil;
        self.url = nil;
        self.gid = nil;
        self.sign = nil;
        self.avatar = nil;
    }
}
- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[ArticleMomentModel class]]) {
        return NO;
    }
    if ([self.ID isEqual:[(ArticleMomentModel *)object ID]]) {
        return YES;
    }
    return NO;
}
- (NSUInteger)hash {
    NSUInteger hash = [self.ID longLongValue];
    return hash;
}
- (NSString *)impressionDescription {
    if (!self.ID) {
        return nil;
    }
    NSString *string = [NSString stringWithFormat:@"%@|%@", self.ID, self.ID];
    return string;
}
- (BOOL)isThreadDeleted {
    if (self.threadStatus == FRThreadEntityStatusTypeDelete) {
        return YES;
    }
    return NO;
}
@end
