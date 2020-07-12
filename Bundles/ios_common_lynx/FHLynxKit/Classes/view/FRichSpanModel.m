//GENERATED CODE , DON'T EDIT
#import "FRichSpanModel.h"
@implementation FRichSpanModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"richText": @"rich_text",
  };
  return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
     return dict[keyName]?:keyName;
  }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FRichSpanRichTextModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"highlightRange": @"highlight_range",
    @"linkUrl": @"link_url",
  };
  return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
     return dict[keyName]?:keyName;
  }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

