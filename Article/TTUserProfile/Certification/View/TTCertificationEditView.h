//
//  TTCertificationEditView.h
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import "SSThemed.h"

#define kItemViewNormalHeight  [TTDeviceUIUtils tt_newPadding:44]
#define kItemViewErrorHeight [TTDeviceUIUtils tt_newPadding:70]

typedef enum {
    TTCertificationEditModelTypeRealName, //真实姓名
    TTCertificationEditModelTypeIdNumber, //身份证号
    TTCertificationEditModelTypeIndustry, //所在行业
    TTCertificationEditModelTypeSupplement, //补充信息
    TTCertificationEditModelTypeUnit,//单位组织
    TTCertificationEditModelTypeOccupational //职位称号
}TTCertificationEditModelType;

@interface TTCertificationEditModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *regex;
@property (nonatomic, copy) NSString *lenIsNullTip;
@property (nonatomic, copy) NSString *patternTip;
@property (nonatomic, copy) NSString *lenShortTip;
@property (nonatomic, copy) NSString *currentErrorTip;
@property (nonatomic, copy) NSString *maxLengthTip;
@property (nonatomic, assign) NSInteger maxLimitLength;
@property (nonatomic, assign) NSInteger minLimitLength;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign, readonly) BOOL isCompleted;
@property (nonatomic, copy) void (^arrowBlock)();
@property (nonatomic, assign) TTCertificationEditModelType type;

@end

@interface TTCertificationEditItemView  : SSThemedView

@property (nonatomic, strong) TTCertificationEditModel *editModel;

@end

@interface TTCertificationEditView : SSThemedView
@property (nonatomic, strong) NSArray<TTCertificationEditModel *> *editModels;
@property (nonatomic, copy) void (^heightChangeBlock)();
@property (nonatomic, copy) void (^textChangeBlock)(TTCertificationEditModel *changeModel);
- (void)updateEidtModel:(TTCertificationEditModel *)editModel;
@end

@interface TTCertificationEditViewMetaDataManager : NSObject

+ (instancetype)sharedInstance;
- (TTCertificationEditModel *)editModelWithType:(TTCertificationEditModelType)type;
- (void)updateModelHeight;
- (void)clearAllData;

@end
