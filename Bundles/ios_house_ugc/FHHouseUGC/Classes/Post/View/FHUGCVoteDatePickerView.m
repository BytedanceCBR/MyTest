//
//  FHUGCVoteDatePickerView.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/12/27.
//

#import "FHUGCVoteDatePickerView.h"
#import "UIColor+Theme.h"
#import <UIFont+House.h>

@interface FHUGCVoteDatePickerView() <UIPickerViewDataSource, UIPickerViewDelegate>

// 最小日期
@property (nonatomic, strong) NSDate *minimumDate;

// 最大日期
@property (nonatomic, strong) NSDate *maximumDate;

// 选择器数据源
@property (nonatomic, strong) NSArray<NSArray<NSString *> *> *dateArray;

// 日期字符串
@property (nonatomic, strong) NSMutableArray<NSString *> *dateComponent;

// 24小时制小时 0 - 23
@property (nonatomic, strong) NSMutableArray<NSString *> *hourComponent;

// 分钟 00-59
@property (nonatomic, strong) NSMutableArray<NSString *> *minuteComponent;

// 日期格式化
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

// 字符串转日期
@property (nonatomic, strong) NSDateFormatter *selectedDateFormatter;

@end

@implementation FHUGCVoteDatePickerView

- (NSDateFormatter *)dateFormatter {
    if(!_dateFormatter) {
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _dateFormatter;
}

- (NSDateFormatter *)selectedDateFormatter {
    if(!_selectedDateFormatter) {
        _selectedDateFormatter = [NSDateFormatter new];
        [_selectedDateFormatter setDateFormat:@"yyyy-MM-ddHHmm"];
    }
    return _selectedDateFormatter;
}

- (NSArray<NSArray<NSString *> *> *)dateArray {
    
    if(!_dateArray) {
    
        NSMutableArray<NSMutableArray<NSString *> *> *components = [NSMutableArray array];

        [components addObject:self.dateComponent];
        [components addObject:self.hourComponent];
        [components addObject:self.minuteComponent];
        
        _dateArray = components;
    }
    
    return _dateArray;
}

- (NSMutableArray<NSString *> *)dateComponent {
    if(!_dateComponent) {
        NSMutableArray *dateItems = [NSMutableArray array];
        
        if([self.maximumDate timeIntervalSinceDate:self.minimumDate] > 0) {
            NSDate *date = self.minimumDate;
            do{
                [dateItems addObject:[self formatDate:date]];
                date = [NSDate dateWithTimeInterval:24 * 60 * 60 sinceDate:date];
            }
            while ([self.maximumDate timeIntervalSinceDate:date] >= 0);
        }
        _dateComponent = dateItems.copy;
    }
    return _dateComponent;
}

- (NSArray<NSString *> *)hourComponent {
    if(!_hourComponent) {
        NSMutableArray *hourItems = [NSMutableArray array];
        for(int i = 0; i < 24; i++) {
            [hourItems addObject:[self twoDigitFormat:i]];
        }
        _hourComponent = hourItems.copy;
    }
    return _hourComponent;
}

- (NSMutableArray<NSString *> *)minuteComponent {
    if(!_minuteComponent) {
        NSMutableArray *minuteItems = [NSMutableArray array];
        for(int i = 0; i < 60; i++) {
            [minuteItems addObject:[self twoDigitFormat:i]];
        }
        _minuteComponent = minuteItems.copy;
    }
    return _minuteComponent;
}

- (NSString *)twoDigitFormat:(int) num {
    return [NSString stringWithFormat:@"%02d", num];
}

- (instancetype)initWithFrame:(CGRect)frame minimumDate: (NSDate *)minimumDate maximumDate: (NSDate *)maximumDate {
    if(self = [super initWithFrame:frame]) {
        
        self.delegate = self;
        self.dataSource = self;
        
        self.minimumDate = minimumDate;
        self.maximumDate = maximumDate;
    }
    return self;
}

- (NSString *)formatDate:(NSDate *)date {
    return [self.dateFormatter stringFromDate:date];
}

- (NSDate *)selectedDateFromString: (NSString *)formattedString {
    return [self.selectedDateFormatter dateFromString:formattedString];
}

- (NSDate *)date {
    
    NSMutableString *formattedString = [NSMutableString string];
    
    for(int component = 0; component < self.numberOfComponents; component++) {
        
        NSInteger row = [self selectedRowInComponent:component];
        
        [formattedString appendFormat:@"%@", self.dateArray[component][row]];
    }
    
    return [self selectedDateFromString:formattedString];
}

- (void)setDate:(NSDate *)date {
    
    NSString *dateString = [self formatDate:date];
    
    NSUInteger unitflags = NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *dateComponent = [[NSCalendar currentCalendar] components:unitflags fromDate:date];
    
    int hour = [dateComponent hour];
    int minute = [dateComponent minute];
    
    
    if(self.numberOfComponents >= 3) {
        NSInteger dateRow = [self.dateArray[0] indexOfObject:dateString];
        NSInteger hourRow = [self.dateArray[1] indexOfObject:[self twoDigitFormat:hour]];
        NSInteger minuteRow = [self.dateArray[2] indexOfObject:[self twoDigitFormat:minute]];
        
        NSArray<NSNumber *> *rows = @[@(dateRow), @(hourRow), @(minuteRow)];
        
        for(int component = 0; component < 3; component++) {
            [self selectRow:rows[component].integerValue inComponent:component animated:NO];
        }
    }
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.dateArray.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dateArray[component].count;
}

#pragma mark - UIPickerViewDelegate

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSMutableAttributedString *attributeTitleString = [[NSMutableAttributedString alloc] initWithString:self.dateArray[component][row] attributes:@{
        NSForegroundColorAttributeName: [UIColor themeGray1],
        NSFontAttributeName: [UIFont themeFontRegular:32]
    }];
    
    return attributeTitleString;
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if(component == 0) {
        return 150;
    } else {
        return 50;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 34;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
}
@end
