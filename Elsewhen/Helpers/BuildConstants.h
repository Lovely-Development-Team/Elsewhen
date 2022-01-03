//
//  BuildConstants.h
//  Elsewhen
//
//  Created by David Stephens on 02/01/2022.
//

#ifndef BuildConstants_h
#define BuildConstants_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(BuildConstants)
@interface CABuildConstants : NSObject
@property (class, nonatomic, readonly) NSDate *buildDate;
@property (class, nonatomic, readonly) NSInteger buildYear;
@property (class, nonatomic, readonly) NSString *buildYearString;
@end

NS_ASSUME_NONNULL_END

#endif /* BuildConstants_h */
