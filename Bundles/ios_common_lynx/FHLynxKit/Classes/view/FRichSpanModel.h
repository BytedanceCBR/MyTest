//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FRichSpanRichTextModel<NSObject>
@end

@interface FRichSpanRichTextModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray *highlightRange;
@property (nonatomic, copy , nullable) NSString *linkUrl;
@end

@interface FRichSpanModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, strong , nullable) NSArray<FRichSpanRichTextModel> *richText;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER