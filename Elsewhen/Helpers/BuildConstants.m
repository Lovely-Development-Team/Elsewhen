//
//  BuildConstants.m
//  Elsewhen
//
//  Created by David Stephens on 02/01/2022.
//

#import "BuildConstants.h"

@implementation EWBuildConstants

/**
 Gets the __DATE__ predef as a string ObjC can work with
 */
+ (NSString *) buildDateString {
    static NSString *buildDate = nil;
    static dispatch_once_t dispatchOnce;
    dispatch_once(&dispatchOnce, ^{
        buildDate = [NSString stringWithUTF8String:__DATE__];
    });
    return buildDate;
}

/**
 Gets the date of this build by parsing the string expanded from the __DATE__ predef
 
 @return The date of the currently-running build
 */
+ (NSDate *) buildDate {
    static NSDate *buildDate = nil;
    static dispatch_once_t dispatchOnce;
    dispatch_once(&dispatchOnce, ^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // This happens the odd format that the compiler uses for the __DATE__ predef
        [dateFormatter setDateFormat:@"MM-dd-yyyy"];
        buildDate = [dateFormatter dateFromString:EWBuildConstants.buildDateString];
    });
    return buildDate;
}

/**
 @return The year of the currently-running build
 */
+ (NSInteger) buildYear {
    static NSInteger buildYear;
    static dispatch_once_t dispatchOnce;
    dispatch_once(&dispatchOnce, ^{
        buildYear = [[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:EWBuildConstants.buildDate];
    });
    return buildYear;
}

/**
 @return The string-ified year of the currently-running build, without any grouping seperators (i.e. "2022" rather than "2,022""
 */
+ (NSString *) buildYearString {
    static NSString *buildYearString;
    static dispatch_once_t dispatchOnce;
    dispatch_once(&dispatchOnce, ^{
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        numberFormatter.usesGroupingSeparator = NO;
        NSNumber *buildYear = [NSNumber numberWithInteger:EWBuildConstants.buildYear];
        buildYearString = [numberFormatter stringFromNumber:buildYear];
    });
    return buildYearString;
}

@end
