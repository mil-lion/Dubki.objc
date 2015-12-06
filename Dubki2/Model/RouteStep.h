//
//  RouteStep.h
//  Dubki2
//
//  Created by Игорь Моренко on 18.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

// Структура для хранения одного шага маршрута
@interface RouteStep : NSObject

@property (strong, nonatomic) NSString *from;      // откуда (станция метро, ж/д, автобуса)
@property (strong, nonatomic) NSString *to;        // куда (станция метро, ж/д, автобуса)
@property (strong, nonatomic) NSDate *departure;   // время отправления
@property (strong, nonatomic) NSDate *arrival;     // время прибытия
@property (assign, nonatomic) NSInteger duration;  // время в пути (в минутах)

// заголовок шага - вид шага и время в пути (для вывода на экран)
@property (readonly) NSString *title;
// описание шага - станции откуда/куда и время отправления/прибытия (для вывода на экран)
@property (readonly) NSString *detail;

@end
