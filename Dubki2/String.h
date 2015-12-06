//
//  String.h
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MyExtension)

@property (readonly, copy) NSDate *date;

- (NSDate *)date:(NSString *)format;

@end
