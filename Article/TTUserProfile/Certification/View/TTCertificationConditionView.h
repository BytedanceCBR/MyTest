//
//  TTCertificationConditionView.h
//  Article
//
//  Created by wangdi on 2017/5/17.
//
//

#import "SSThemed.h"

typedef enum {
    TTCertificationConditionTypeIcon,
    TTCertificationConditionTypeUserName,
    TTCertificationConditionTypeBindPhone,
    TTCertificationConditionTypeAvailableFanCount,
    TTCertificationConditionTypeWeitoutiao,
}TTCertificationConditionType;

@interface TTCertificationConditionModel : NSObject

@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *regexText;
@property (nonatomic, assign) BOOL isCompletion;
@property (nonatomic, assign) BOOL hiddenBottomLine;
@property (nonatomic, assign) TTCertificationConditionType type;

@end

@interface TTCertificationConditionCell : SSThemedTableViewCell

@property (nonatomic, strong) TTCertificationConditionModel *model;
@end

@interface TTCertificationConditionHeaderView : SSThemedView

@end
