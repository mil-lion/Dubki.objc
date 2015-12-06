//
//  Date.m
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "Date.h"

@implementation NSDate (MyExtension)

#pragma mark - Property

- (NSString *)string {
    return [self stringByFormat:@"yyyy-MM-dd HH:mm:ss"];
}

/*
 The number of the weekday unit for the receiver.
 Weekday units are the numbers 1 through n, where n is the number of days in the week. For example, in the Gregorian calendar, n is 7 and Sunday is represented by 1.
 */
- (NSInteger)weekday {
    //let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    return [[NSCalendar currentCalendar] component:NSCalendarUnitWeekday fromDate:self];
}

- (NSString *)weekdayName {
    return [self stringByFormat:@"EEEE"];
    //let weekdayName = ["воскресенье", "понедельник", "вторник", "среда", "четверг", "пятница", "суббота"]
    //return weekdayName[weekday - 1]
}

#pragma mark - Method

- (NSString *)stringByFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:self];
}

- (NSDate *)dateByAddingMinute:(NSInteger)minute {
    //return [self dateByAddingTimeInterval:(minute * 60)];
    return [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMinute
                                                    value:minute toDate:self
                                                  options:0];
//    if (#available(iOS 8.0, *)) {
//        return calendar.dateByAddingUnit([.Minute], value: minute, toDate: self, options: [])
//    } else {
//        // Fallback on earlier versions
//        let components = NSDateComponents()
//        components.minute = minute
//        return calendar.dateByAddingComponents(components, toDate: self, options: [])
//    }
}

- (NSDate *)dateByAddingDay:(NSInteger)day {
    //let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    return [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay
                                                    value:day toDate:self
                                                  options:0];
//    if #available(iOS 8.0, *) {
//        return calendar.dateByAddingUnit([.Day], value: day, toDate: self, options: [])
//    } else {
//        // Fallback on earlier versions
//        let components = NSDateComponents()
//        components.day = day
//        return calendar.dateByAddingComponents(components, toDate: self, options: [])
//    }
}

- (NSDate *)dateByWithTime:(NSString *)time {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd ";
    
    NSString *dateString = [[dateFormatter stringFromDate:self] stringByAppendingString:time];
    
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    
    return [dateFormatter dateFromString:dateString];
}

// get interval from two date (of date on further date and pass the earlier date as parameter, this would give the time difference in seconds)
//let interval = date1.timeIntervalSinceDate(date2)

// get component from date
//let date = NSDate()
//let calendar = NSCalendar.currentCalendar()
//let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
//let hour = components.hour
//let minutes = components.minute
@end
