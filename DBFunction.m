//
//  DBFunction.m
//
//
//  Created by Prashant Belani on 16/11/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "DBFunction.h"

@implementation DBFunction

+(NSArray*)getAllFavoriteEmoji
{
    return [DBOperation selectData:[NSString stringWithFormat:@"SELECT * FROM tblfavourite"]];
}

@end
