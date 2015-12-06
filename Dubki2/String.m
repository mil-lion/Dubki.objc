//
//  String.m
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "String.h"

@implementation NSString (MyExtension)

- (NSDate *)date {
    return [self date:@"yyyy-MM-dd HH:mm:ss"];
}

- (NSDate *)date:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter dateFromString:self];
}

@end
