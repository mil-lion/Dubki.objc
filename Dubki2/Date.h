//
//  Date.h
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MyExtension)

@property (readonly, copy) NSString *string;
@property (readonly) NSInteger weekday;
@property (readonly, copy) NSString *weekdayName;

- (NSString *)stringByFormat:(NSString *)format;
- (NSDate *)dateByAddingMinute:(NSInteger)minute;
- (NSDate *)dateByAddingDay:(NSInteger)day;
- (NSDate *)dateByWithTime:(NSString *)time;

@end
