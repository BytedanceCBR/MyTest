
#import "TTApiParameter.h"
#import "TTGroupModel.h"

@interface TTVideoFloatParameter : TTApiParameter
@property (strong, nonatomic) NSNumber *comment_id;
@property (copy, nonatomic) NSString *zzids;
@property (copy, nonatomic) NSString *cateoryID;
@property (copy, nonatomic) NSString *from;
@property (strong, nonatomic) NSNumber *flags;
@property (strong, nonatomic) NSNumber *article_page;
@property (strong, nonatomic) TTGroupModel *groupModel;
@property (copy, nonatomic) NSString *videoSubjectID;
@property (copy, nonatomic) NSString *ad_id;
@end
