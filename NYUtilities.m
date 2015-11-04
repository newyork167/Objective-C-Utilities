//
//  NYUtilites.m
//  metolius_concept_ios7_A1
//
//  Created by Cody Dietz on 1/23/15.
//  Copyright (c) 2015 FCS. All rights reserved.
//
//  Utility functions
//

#import "NYUtilities.h"
#import "CBZipFile.h"
#import "Alert.h"
#import "DataField.h"
#import "AppDelegate.h"

@implementation NYUtilites

#pragma mark - NSDATA TO HEX METHODS

/**
 Converts NSData object into NSString object to work with
 
 @param spaces Whether or not you want spaces every spaceEveryThisManyBytes
 @param data   NSData object from CBCharacteristic
 
 @return NSString containing hex data
 */
+(NSString*)hexRepresentationWithSpaces_AS:(BOOL)spaces data:(NSData *)data
{
    const unsigned char* bytes = (const unsigned char*)[data bytes];
    NSUInteger nbBytes = [data length];
    
    // If spaces is true, insert a space every this many input bytes
    // (twice this many output characters due to bytes being 2 characters).
    static const NSUInteger spaceEveryThisManyBytes = 4UL;
    // If spaces is true, insert a line-break instead of a space every this many spaces. Set to 1UL for no line breaks.
    static const NSUInteger lineBreakEveryThisManySpaces = 4UL;
    
    const NSUInteger lineBreakEveryThisManyBytes = spaceEveryThisManyBytes * lineBreakEveryThisManySpaces;
    NSUInteger strLen = 2*nbBytes + (spaces ? nbBytes/spaceEveryThisManyBytes : 0);
    
    NSMutableString* hex = [[NSMutableString alloc] initWithCapacity:strLen];
    for(NSUInteger i=0; i<nbBytes; ) {
        [hex appendFormat:@"%02X", bytes[i]];
        // We need to increment here so that the every-n-bytes computations are right.
        ++i;
        
        if (spaces) {
            if (i % lineBreakEveryThisManyBytes == 0) [hex appendString:@"\n"];
            else if (i % spaceEveryThisManyBytes == 0) [hex appendString:@" "];
        }
    }
    return hex;
}

/**
 Converts NSData to Hex string
 
 @param data NSData to convert
 
 @return Hex string representation
 */
+(NSString *)dataToHexadecimalString:(NSData *)data {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger dataLength  = [data length];
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

#pragma mark - GETTER METHODS FOR HEX STRINGS

/**
 Gets status bits from sent hexstring
 
 @param hexString String representing returned data
 
 @return Status bits in decimal format
 */
+(NSInteger)getStatusFromModbusHexString:(NSString *)hexString{
    return [self convertHexToDecimal:[hexString substringWithRange:NSMakeRange(4, 4)] littleEndian:YES];
}

/**
 Get size of payload from sent hexstring
 
 @param hexString String representing returned data
 
 @return Size in decimal format
 */
+(NSInteger)getSizeFromModbusHexString:(NSString *)hexString{
    if ([hexString length] < 10)
        return 0;
    return ![hexString length] ? 0 : [self convertHexToDecimal:[hexString substringWithRange:NSMakeRange(8, 2)] littleEndian:NO];
}

/**
 Gets data from hexstring payload
 
 @param hexString String representing returned data
 
 @return Payload data in decimal format
 */
+(NSInteger)getDataFromModbusHexString:(NSString *)hexString{
    NSInteger size = [self getSizeFromModbusHexString:hexString] * 2;
    NSString *payloadString = [hexString substringWithRange:NSMakeRange(10, size)];
    
    return [self convertHexToDecimal:payloadString littleEndian:YES];
}

/**
 Gets CRC 32 from hexstring
 
 @param hexString String representing returned data
 
 @return CRC 32 data in decimal format
 */
+(NSInteger)getCrc32FromModbusHexString:(NSString *)hexString{
    return [self convertHexToDecimal:[hexString substringWithRange:NSMakeRange([hexString length] - 8, 8)] littleEndian:YES];
}

#pragma mark - HEX TO DECIMAL METHODS

/**
 Converts hex formatted string to decimal formatted string
 
 @param hexNumberString String representing hex data
 
 @return Decimal format of hex string
 */
+(NSUInteger)convertHexToDecimal:(NSString *)hexNumberString littleEndian:(BOOL)endian{
    NSString *tempNumber = hexNumberString;
    if (endian) {
        tempNumber = [self littleEndianToBigEndian:tempNumber];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:tempNumber];
    unsigned int decimalNumber;
    [scanner scanHexInt:&decimalNumber];
    
    return decimalNumber;
}

/**
 Converts hex formatted string to decimal formatted string

 @param hexNumberString String representing hex data

 @return Decimal format of hex string
 */
+(NSInteger)convertHexToSignedDecimal:(NSString *)hexNumberString littleEndian:(BOOL)endian{
    NSString *tempNumber = hexNumberString;
    if (endian) {
        tempNumber = [self littleEndianToBigEndian:tempNumber];
    }

    NSScanner *scanner = [NSScanner scannerWithString:tempNumber];
    unsigned int decimalNumber;
    [scanner scanHexInt:&decimalNumber];

    return (int)decimalNumber;
}

/**
 Converts hex to float
 
 @param hexNumberString Hex string to convert
 @param endian          Whether string needs to be converted to big endian
 
 @return Float version of hex
 */
+(float)convertHexToFloat:(NSString *)hexNumberString isLittleEndian:(BOOL)endian{
    if(endian)
        hexNumberString = [NYUtilites littleEndianToBigEndian:hexNumberString];
    
    uint32_t num;
    float f;
    sscanf([hexNumberString cStringUsingEncoding:NSASCIIStringEncoding], "%x", &num);
    f = *((float*)&num);
    
    return f;
}

#pragma mark - DECIMAL TO HEX METHODS

/**
 Converts decimal number to hex string

 @param decimal Decimal number to convert
 
 @return String with hex value
 */
+(NSString *)convertDecimalToHex:(NSNumber *)decimal littleEndian:(BOOL)endian{
    NSString *temp;
    NSInteger integer = [decimal integerValue];
    
    if(!endian) {
        temp = [NSString stringWithFormat:@"%lx", (unsigned long)integer];
    }
    else {
        temp = [self littleEndianToBigEndian:[NSString stringWithFormat:@"%lx", (unsigned long)integer]];
    }
    
    temp = [NSString stringWithFormat:@"%@", temp];
    
    return temp;
}

/**
 Convert decimal to hex in UInt32
 
 @param decimal     Decimal to convert
 @param endian      Whether or not to swap endianess of hex
 @param numBytes    Number of bytes to convert
 
 @return UInt32 in hex format
 */
+(UInt32)convertDecimalToHex:(NSInteger)decimal endianSwap:(BOOL)endian bytes:(int)numBytes{
    if (!endian) {
        return (numBytes == 4 ? 0xFFFF : 0xFFFFFFFF) & decimal;
    }
    else{
        return numBytes == 4 ? htons(0xFFFF & decimal) : htons(0xFFFFFFFF & decimal);
    }
}

#pragma mark - ENDIAN CONVERSION METHODS

/**
 Converts string from little endian to big endian
 
 @param string String to convert
 
 @return String in big endian format
 */
+(NSString *)littleEndianToBigEndian:(NSString *)string{
    NSMutableString *bigEndianString = [NSMutableString new];
    
    bool setLeadingZero = [string length] % 2;
    
    for (NSInteger pos = [string length]; pos > 0; pos -= 2) {
        if (pos <= 2 && setLeadingZero) {
            [bigEndianString appendString:@"0"];
            [bigEndianString appendString:[string substringWithRange:NSMakeRange(pos - 1, 1)]];
        }
        else{
            [bigEndianString appendString:[string substringWithRange:NSMakeRange(pos - 2, 2)]];
        }
    }
    
    return bigEndianString;
}

/**
 Converts string from little endian to big endian
 
 @param string String to convert
 @param int    Amount to shift by, e.g. 111222333 shifted 3 => 333222111, shifted 2 => 3323221211
 
 @return String in big endian format
 */
+(NSString *)littleEndianToBigEndian:(NSString *)string bitShiftAmount:(int)shift{
    NSMutableString *bigEndianString = [NSMutableString new];
    
    for (NSInteger pos = (NSInteger)[string length]; pos > 0; pos -= shift) {
        [bigEndianString appendString:[string substringWithRange:NSMakeRange(pos - shift, shift)]];
    }
    
    return bigEndianString;
}

/**
 *  Decimal to binary string
 *
 *  @param dec Decimal to convert
 *
 *  @return String containing binary value
 */
+(NSString *)decToBin:(NSInteger)dec{
    NSMutableString *binary = [NSMutableString new];

    do {
        [binary appendFormat:@"%li", dec & 1];
    } while(dec >>= 1);

    return binary;
}

/**
 *  Pads string with specified pad characters
 *
 *  @param string    String to pad
 *  @param padString Pad string to pad with
 *  @param length    How many times to add padded string
 *  @param left      Whether to add pad string on left of right
 *
 *  @return Padded string
 */
+(NSString *)padString:(NSString *)string padWith:(NSString *)padString totalLength:(NSInteger)length padLeft:(BOOL)left {
    NSInteger padLength = length - [string length];

    for (int pad = 0; pad < padLength; pad++){
        string = [NSString stringWithFormat:@"%@%@", left ? padString : string, left ? string : padString];
    }

    return string;
}

/**
 *  Reverses string
 *
 *  @param string String to reverse
 *
 *  @return Reversed string
 */
+(NSString *)reverseString:(NSString *)string{
    NSMutableString *reversedString = [NSMutableString new];

    for (NSInteger ch = [string length] - 1; ch >= 0; ch--){
        [reversedString appendFormat:@"%@", [string substringWithRange:NSMakeRange(ch, 1)]];
    }

    return reversedString;
}

/**
 Returns whether or not the current time - the start time is greater than the time allotted
 
 @param startTime Start Time
 @param time      Allotted Time
 
 @return Whether time has gone over or not
 */
+(bool)howIsTime:(NSTimeInterval)startTime timeAllotted:(NSInteger)time{
    return [[NSDate date] timeIntervalSince1970] - startTime > time;
}

#pragma mark - DEBUG METHODS

/**
 DEBUG - Function to test HexObject
 */
+(void)test{
    
    HexObject *obj = [[HexObject alloc] initWithReadWrite:1 size:2];
    
    [obj setPayload:@[@131]];
    
    NSLog(@"Data Created: %@", [obj getDataPacket]);
}

/**
* Returns random number between bounds inclusively
*
* @param lowerBounds Lowest number to allow random to return
* @param upperBounds Highest number to allow random to return
* @param inclusive Whether or not to include the bounds
*
* @return Random number between lowerBounds and upperBounds
*/
+(int)generateRandomNumberWithLowerBounds:(NSInteger)lower upperBounds:(NSInteger)upper inclusive:(BOOL)inclusive{
    // Create the random number, adding +1 to allow upper bound to be inclusive
    int randNum = arc4random() % ((int)upper - lower + (inclusive ? 1 : 0)) + lower;
    return randNum;
}


#pragma mark NSARRAY METHODS

/**
 *  Converts array containing arrays to a singular array
 *
 *  @param outer Array to convert
 *
 *  @return Array containing all elements of subarrays
 */
+(NSArray *)convertArrayOfArrayToArray:(NSArray *)outer{
    NSMutableArray *returnArray = [NSMutableArray new];

    for (NSArray *inner in outer){
        [returnArray addObject:inner[0]];
    }

    returnArray = [[self sortArrayOfNumbers:returnArray] mutableCopy];

    return returnArray;
}

+(void)dispatch_serial_group:(void (^)(void))block{
    dispatch_group_async([[AsyncController sharedManager] serialQueueGroup], [[AsyncController sharedManager] serialQueue], block);
}

+(void)dispatch_serial_queue:(void (^)(void))block{
    dispatch_async([[AsyncController sharedManager] serialQueue], block);
}

+(void)dispatch_main_queue:(void (^)(void))block{
    dispatch_async(dispatch_get_main_queue(), block);
}

/**
 *  Splits number array into continuous blocks
 *
 *  @param array Array to split
 *
 *  @return Split array
 */
+(NSArray *)splitArray:(NSArray *)array {
    NSMutableArray *returnArray = [NSMutableArray new];
    NSInteger maxArraySize = 20;

    array = [NYUtilites quicksortNumberArray:[array mutableCopy]];

    NSNumber *previousNum = @([[array firstObject] integerValue]);
    NSMutableArray *addArray = [NSMutableArray new];

    // Loop through and add group all numbers
    for (NSNumber *currentNum in array) {
        if (([currentNum integerValue] > [previousNum integerValue] + 1) || addArray.count >= maxArraySize ) {
            [returnArray addObject:[addArray copy]];
            [addArray removeAllObjects];
            [addArray addObject:currentNum];
        }
        else {
            [addArray addObject:currentNum];
        }

        previousNum = currentNum;
    }

    if (![[returnArray lastObject] isEqualToArray:addArray])
        [returnArray addObject:addArray];

    return returnArray;
}

/**
 *  Chunks array into specified sizes
 *
 *  @param array Array to chunk
 *  @param size  Size to chunk
 *
 *  @return Processed array
 */
+(NSArray *)chunkArray:(NSArray *)array IntoChunksSize:(NSInteger)size{
    NSMutableArray *returnArray = [NSMutableArray new];

    NSInteger itemsRemaining = [array count];
    NSUInteger j = 0;

    while(j < [array count]) {
        NSRange range = NSMakeRange(j, (NSUInteger) MIN(size, itemsRemaining));
        NSArray *subarray = [array subarrayWithRange:range];
        [returnArray addObject:subarray];
        itemsRemaining -= range.length;
        j += range.length;
    }

    return returnArray;
}

/**
 *  Converts and splits array into chunks
 *
 *  @param array Array to process
 *
 *  @return Array containing chunked information
 */
+(NSArray *)convertAndSplitArray:(NSArray *)array{
    array = [self convertArrayOfArrayToArray:array];
    return [self splitArray:array];
}

/**
 *  Sort array of numbers
 *
 *  @param array Array to support
 *
 *  @return Sorted array
 */
+(NSArray *)sortArrayOfNumbers:(NSArray *)array{
    NSMutableArray *returnArray = [array mutableCopy];

    returnArray = [[returnArray sortedArrayUsingSelector:@selector(compare:)] mutableCopy];

    return returnArray;
}

/**
 *  Set up array into 20 number chunks for getting information
 *
 *  @param array Array to process
 *
 *  @return Sorted array in 20 number chunks
 */
+(NSArray *)setupArrayForProcessing:(NSArray *)array{
    NSMutableArray *editArray = [array mutableCopy];
    NSMutableArray *returnArray = [NSMutableArray new];

    editArray = [[self convertArrayOfArrayToArray:editArray] mutableCopy];
    editArray = [[self sortArrayOfNumbers:editArray] mutableCopy];
    editArray = [[self splitArray:editArray] mutableCopy];

    for (NSArray *innerArray in editArray){
        NSArray *a = [self chunkArray:innerArray IntoChunksSize:20];
        for (NSArray *b in a){
            [returnArray addObject:b];
        }
    }

    return returnArray;
}

/**
 *  Set up array for monitoring - Chunks into 20 numbers at a time
 *
 *  @param array Array to setup
 *
 *  @return Array containing formatted address information
 */
+(NSArray *)setupArrayForMonitoring:(NSArray *)array{
    NSMutableArray *editArray = [array mutableCopy];
    NSMutableArray *returnArray = [NSMutableArray new];

    editArray = [[self sortArrayOfNumbers:editArray] mutableCopy];
    editArray = [[self splitArray:editArray] mutableCopy];

    for (NSArray *innerArray in editArray){
        NSArray *a = [self chunkArray:innerArray IntoChunksSize:20];
        for (NSArray *b in a){
            [returnArray addObject:b];
        }
    }

    return returnArray;
}

#pragma mark - SORTING METHODS

/**
* Custom quicksort implementation for NSNumbers
*
* @param numArray - Array to quicksort
*
* @return Sorted array
*/
+(NSArray *)quicksortNumberArray:(NSArray *)numArray{
    NSMutableArray *returnArray = [NSMutableArray new];
    NSMutableArray *less = [NSMutableArray new];
    NSMutableArray *equal = [NSMutableArray new];
    NSMutableArray *greater = [NSMutableArray new];

    if ([numArray count] <= 1)
        return numArray;

    NSNumber *pivot = numArray[[numArray count] / 2];
    for (NSNumber *num in numArray){
        if ([num integerValue] < [pivot integerValue]){
            [less addObject:num];
        }
        if ([num integerValue] == [pivot integerValue]){
            [equal addObject:num];
        }
        if ([num integerValue] > [pivot integerValue]){
            [greater addObject:num];
        }
    }

    less = [[self quicksortNumberArray:less] mutableCopy];
    greater = [[self quicksortNumberArray:greater] mutableCopy];

    [self appendArray:less toArray:returnArray];
    [self appendArray:equal toArray:returnArray];
    [self appendArray:greater toArray:returnArray];

    return returnArray;
}

/**
 *  Integer to binary character array
 *
 *  @param n Integer to convert
 *
 *  @return Character array containing binary equivalent
 */
+(char *)decimalToBinary:(int)n
{
    int c, d, count;
    char *pointer;

    count = 0;
    pointer = (char*)malloc(32+1);

    if ( pointer == NULL )
        exit(EXIT_FAILURE);

    for ( c = 31 ; c >= 0 ; c-- )
    {
        d = n >> c;

        *(pointer + count) = (char) ((d & 1 ? 1 : 0) + '0');

//        if ( d & 1 )
//            *(pointer+count) = 1 + '0';
//        else
//            *(pointer+count) = 0 + '0';

        count++;
    }
    *(pointer+count) = '\0';

    return  pointer;
}

/**
 *  Quicksort method for any NSObject and selector
 *
 *  @param array          Array to quicksort
 *  @param selectorString Selector to sort by - If it does not respond to selector array will not change
 *
 *  @return Sorted array by selector
 */
+(NSMutableArray *)quickSortArray:(NSMutableArray *)array bySelector:(NSString *)selectorString{
    if ([array count] <= 1)
        return array;

    NSMutableArray *sortedArray = [NSMutableArray new];
    NSMutableArray *high = [NSMutableArray new];
    NSMutableArray *equal = [NSMutableArray new];
    NSMutableArray *low = [NSMutableArray new];

    NSObject *pivot = array[array.count / 2];
    if (![pivot respondsToSelector:NSSelectorFromString(selectorString)])
        return array;

    for (NSObject *obj in array){
        if ([obj respondsToSelector:NSSelectorFromString(selectorString)]) {
            if ([obj valueForKey:selectorString] > [pivot valueForKey:selectorString])
                [high addObject:obj];
            else if ([obj valueForKey:selectorString] < [pivot valueForKey:selectorString])
                [low addObject:obj];
            else
                [equal addObject:obj];
        }
    }

    low = [self quickSortArray:low bySelector:selectorString];
    high = [self quickSortArray:high bySelector:selectorString];

    [sortedArray addObjectsFromArray:low];
    [sortedArray addObjectsFromArray:equal];
    [sortedArray addObjectsFromArray:high];

    return sortedArray;
}

/**
* Method to append an instance array to another array
*
* @param objects - Array containing objects to be appended
* @param array - Array to append objects from objects array to
*/
+(void)appendArray:(NSArray *)objects toArray:(NSMutableArray *)array{
    for (__autoreleasing id object in objects){
        [array addObject:object];
    }
}

/**
 *  Generates random initilization vector for encryption - 128 bit
 *
 *  @return 128 bit IV
 */
+(NSString *)generateRandomInitilizationVector{
    NSMutableString *iv = [NSMutableString new];
    NSDictionary *hexDict = @{@10 : @"A", @11 : @"B", @12 : @"C", @13 : @"D", @14 : @"E", @15 : @"F"};

    NSInteger upperBounds = 15, lowerBounds = 0;
    for (int character = 0; character < 16; character++){
        NSNumber *num = @([self generateRandomNumberWithLowerBounds:lowerBounds upperBounds:upperBounds inclusive:YES]);
        [iv appendFormat:@"%@", [num integerValue] > 10 ? hexDict[num] : num];
    }

    return iv;
}

/**
 *  Converts hex encoded string to data with same representation
 *      E.g. "ABCD1234" will convert to <ABCD1234>
 *
 *  @param dataString Data string to convert to NSData
 *
 *  @return NSData containing hex encoded information
 */
+(NSData *)convertHexStringToHexData:(NSString *)dataString{
    NSString *string = dataString;
    //char *hexdata = "350100000400000100d3f9615d";
    char *pDataString = calloc([string length] + 1, sizeof(char));
    
    for (int i = 0; i < [string length]; i++) {
        pDataString[i] = [string characterAtIndex:i];
    }
    
    pDataString[[string length]] = '\0';
    
//    strcpy(pDataString, [string UTF8String]);

    char unsigned data[(strlen(pDataString) / 2)];
    int temp;

    // Loop through header packets at size 2 and set data to hex value
    for (int first = 0; first < [dataString length]; first += 2) {
        sscanf(&pDataString[first], "%02x", &temp);
        data[first / 2] = temp;
    }
    
    free(pDataString);

    // Create NSData packet
    NSData *tmpData = [NSData dataWithBytes:data length:sizeof(data)/sizeof(data[0])];

    // Return NSData packet with hex data
    return tmpData;
}


#pragma mark - MISC METHODS
/**
 Converts float to formatted string to show decimal when needed (< 10 show tens, < 1 show hundreds if available)
 
 @param data float to convert
 
 @return float string representation
 */
+(NSString *)floatToFormattedString:(float)data {
    /* Returns a formatted string from float. Empty string if data is empty.   */
    if(data>= 10 || data == 0){
        return [NSString stringWithFormat:@"%.1f", data];
    }
    else if(data >= 1 && data < 10)
    {
        if(fmod(data,1) == 0){
            return [NSString stringWithFormat:@"%.0f", data];
        }
        return [NSString stringWithFormat:@"%.1f", data];
    }
    else {
        if(fmod(data,1) == 0){
            return [NSString stringWithFormat:@"%.0f", data];
        }
        return [NSString stringWithFormat:@"%.2f", data];
    }
}

/**
 *  Convert ASCII string to hex string
 *
 *  @param asciiString ASCII encoded string
 *
 *  @return Hex encoded string
 */
+(NSString *)convertAsciiStringToHexString:(NSString *)asciiString{
    NSString * hexStr = [NSString stringWithFormat:@"%@",
                                                   [NSData dataWithBytes:[asciiString cStringUsingEncoding:NSUTF8StringEncoding]
                                                                  length:strlen([asciiString cStringUsingEncoding:NSUTF8StringEncoding])]];
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    hexStr = [hexStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    return hexStr;
}

+(NSData *)convertAsciiStringToHexData:(NSString *)asciiString{
//    return [self convertHexStringToHexData:asciiString];
    NSString *hexString = [self convertAsciiStringToHexString:asciiString];
    NSData *hexData = [self convertHexStringToHexData:hexString];
    return hexData;
}

/**
 *  Convert binary to hex encoded string
 *
 *  @param data Data to convert to string
 *
 *  @return Hex encoded string
 */
+(NSString *)convertDataToString:(NSData *)data{
    NSString* newStr = [self hexRepresentationWithSpaces_AS:NO data:data];
    return newStr;
}

/**
 *  Creates QR image from string
 *
 *  @param qrString String to convert to QR image
 *
 *  @return Image object containing QR code
 */
+ (CIImage *)createQRForString:(NSString *)qrString
{
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding: NSISOLatin1StringEncoding];

    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    if ([qrFilter respondsToSelector:@selector(setValue:forKey:)]) {
        @try {
            [qrFilter setValue:stringData forKey:@"inputMessage"];
        }
        @catch (NSException *exception1){
            NSLog(@"Exception occured creating qr code: %@", exception1);
        }
    }
    if ([qrFilter respondsToSelector:@selector(setValue:forKey:)]) {
        @try{
            [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
        }
        @catch (NSException *ex){
            NSLog(@"Exception occured creating qr code: %@", ex);
        }
    }

    // Send the image back
    return qrFilter.outputImage;
}

/**
 *  Unzips file into NSArray containing NSData elements
 *
 *  @param filePath Path of file to unzip
 *
 *  @return Array containing binary data elements
 */
+(NSDictionary *)unzipZipFileAtPath:(NSString *)filePath{
//    NSMutableArray *files = [NSMutableArray new];
    NSMutableDictionary *files = [NSMutableDictionary new];

    if (![[filePath substringFromIndex:[filePath length] - 4] isEqualToString:@".zip"])
        filePath = [filePath stringByAppendingFormat:@".zip"];
    CBZipFile *zipFile = [[CBZipFile alloc] initWithFileAtPath:filePath];
    [zipFile open];
    NSArray *filenames = [zipFile fileNames];
    [zipFile buildHashTable];

    for (NSString *file in filenames){
        if ([file rangeOfString:@"__MACOSX"].location == NSNotFound && [file rangeOfString:@".bin"].location != NSNotFound)
            files[file] = [zipFile readWithFileName:file caseSensitive:YES maxLength:NSUIntegerMax];
    }

    [zipFile close];

    return files;
}

+(NSArray *)sortFirmwareZipFileArray:(NSDictionary *)array{
    NSMutableArray *returnArray = [NSMutableArray new];

    for (NSString *key in array){
        if ([key rangeOfString:@"METER"].location != NSNotFound && [returnArray count] < 2){
            [returnArray insertObject:array[key] atIndex:0];
        }
        else if ([key rangeOfString:@"IO"].location != NSNotFound && [returnArray count] < 2)
        {
            [returnArray addObject:array[key]];
        }
    }

    return returnArray;
}

/**
 *  Converts milliseconds to format: ss/HH/dd
 *
 *  @param milliseconds Milliseconds to convert
 *
 *  @return NSDate in ss-HH-dd format
 */
+(NSDate *)millisecondsToStandardDate:(double)milliseconds{
    return [NYUtilites milliseconds:milliseconds toDateFormat:@"ss-HH-dd"];
}

/**
 *  Converts milliseconds to NSDate
 *
 *  @param milliseconds Milliseconds in the past
 *
 *  @return NSDate with date of occurence
 */
+(NSDate *)millisecondsSinceNowToNSDate:(long double)milliseconds{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) -(milliseconds / 1000.0)];
    return date;
}

/**
 *  Calculates signal strength based on how many bars are specified
 *
 *  @param peripheral Peripheral to calculate signal strength
 *  @param bars       Number of bars to calculate for
 *
 *  @return Signal strength in number of bars
 */
+(NSInteger)calculateSignalStrengthForPeripheral:(CBPeripheral *)peripheral withTotalBars:(NSInteger)bars{
    for (NSInteger bar = bars, returnBars = 0; bar > 0; bar--, returnBars++) {
        if (([peripheral.RSSI integerValue] < (-100 * bar) / bars) && ([peripheral.RSSI integerValue] >= (-100 * (bar - 1)) / bars)) {
            return returnBars;
        }
    }
    
    return 0;
}

+(NSArray *)sortArrayOfStrings:(NSArray *)stringArray{
    return [stringArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

+(NSString *)convertHexStringToAsciiString:(NSString *)str{
    NSMutableString * newString = [NSMutableString string];

    NSArray * components = [str componentsSeparatedByString:@" "];
    for (int iChar = 0; iChar < [str length]; iChar += 2){
        int value = 0;
        sscanf([[str substringWithRange:NSMakeRange(iChar, 2)] cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [newString appendFormat:@"%c", (char)value];
    }

    return newString;
}
/**
  * Converts milliseconds to NSDate
  *
  * @param milliseconds Integer milliseconds to convert to date
  * @param dateFormat Date format separated by "-" or "/"
  */
+(NSDate *)milliseconds:(long double)milliseconds toDateFormat:(NSString *)dateFormat{
    NSMutableString *date = [NSMutableString new];
    bool bSeconds = NO, bMinutes = NO, bHours = NO, bDays = NO, bWeeks = NO, bMonths = NO, bYears = NO;
    
    NSArray *componentsOfDateFormat = [dateFormat componentsSeparatedByString:@"-"];
    if (![componentsOfDateFormat count])
        componentsOfDateFormat = [dateFormat componentsSeparatedByString:@"/"];
    
    for (NSString *dateComponent in componentsOfDateFormat){
        SWITCH(dateComponent){
            CASE(@"ss"){
                bSeconds = YES;
            }
            CASE(@"mm"){
                bMinutes = YES;
            }
            CASE(@"HH"){
                bHours = YES;
            }
            CASE(@"dd"){
                bDays = YES;
            }
            CASE(@"ww"){
                bWeeks = YES;
            }
            CASE(@"MM"){
                bMonths = YES;
            }
            CASE(@"yyyy"){
                bYears = YES;
            }
            DEFAULT{
                break;
            }
        }
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    
    int seconds, minutes, hours, days, weeks, months, years;
    
    // Get seconds
    milliseconds /= 1000;
    seconds = (int) fmod((double) milliseconds, 60);
    if (bSeconds) [date appendFormat:@"%@", @(seconds)];
    milliseconds = floor((double) milliseconds);
    
    // Get minutes
    milliseconds /= 60;
    minutes = (int) fmod((double) milliseconds, 60);
    if (bMinutes) [date appendFormat:@"-%@", @(minutes)];
    milliseconds = floor((double) milliseconds);
    
    // Get hours
    milliseconds /= 60;
    hours = (int) fmod(fmod((double) milliseconds, 60), 24);
    if (bHours) [date appendFormat:@"-%@", @(hours)];
    milliseconds = floor((double) milliseconds);
    
    // Get days
    milliseconds /= 24;
    days = (int) fmod((double) milliseconds, 30);
    if (bDays) [date appendFormat:@"-%@", @(days)];
    milliseconds = floor((double) milliseconds);
    
    // Get weeks
    weeks = (int) fmod((double) (milliseconds / 7.0), 4.0);
    milliseconds = floor((double) milliseconds);
    if (bWeeks) [date appendFormat:@"-%@", @(weeks)];
    
    // Get months
    months = (int) fmod((double) (milliseconds / 30), 12);
    if (bMonths) [date appendFormat:@"-%@", @(months)];
    
    // Get years
    years = (int) (milliseconds / 12.0);
    if (bYears) [date appendFormat:@"-%@", @(years)];
    
    // ss/mm/HH/dd/ww/MM/yyyy
    if ([date characterAtIndex:0] == '-'){
        date = [[date substringFromIndex:1] mutableCopy];
    }
    
    NSDate *returnDate = [formatter dateFromString:date];
    return returnDate;
}

/**
 * Converts milliseconds into common date formats
 *
 * @param milliseconds Milliseconds to convert to time chunks
 * @return Array containing most commonly used formats
 */
+(NSArray *)millisecondsToArray:(long double)milliseconds{
    int seconds, minutes, hours, days, weeks, months, years;
    
    // Get seconds
    milliseconds /= 1000;
    seconds = (int) fmod(milliseconds, 60);
    milliseconds = floor(milliseconds);
    
    // Get minutes
    milliseconds /= 60;
    minutes = (int) fmod(milliseconds, 60);
    milliseconds = floor(milliseconds);
    
    // Get hours
    milliseconds /= 60;
    hours = (int) fmod(fmod(milliseconds, 60), 24);
    milliseconds = floor(milliseconds);
    
    // Get days
    milliseconds /= 24;
    days = (int) fmod(milliseconds, 30);
    milliseconds = floor(milliseconds);
    
    // Get weeks
    weeks = (int) fmod((double) (milliseconds / 7.0), 4.0);
    milliseconds = floor(milliseconds);
    
    // Get months
    months = (int) fmod((double) (milliseconds / 30), 12);
    
    // Get years
    milliseconds /= 30;
    //    years = ;
    years = (int) (milliseconds / 12.0);
    
    // Returns array
    return @[@(seconds), @(minutes), @(hours), @(days), @(weeks), @(years)];
}
/**
 *  Resizes an image to the specified CGSize
 *
 *  @param image   image to resize
 *  @param newSize the size that you want to convert the image to
 *
 *  @return a resized UIImage
 */
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(NSDictionary *)convertSecondsToMHDY:(NSUInteger)seconds{
    NSInteger minutes = 0, hours = 0, days = 0, years = 0;

    minutes = (seconds / 60) % 60;
    hours = ((seconds / 60) / 60) % 24;
    days = (((seconds / 60) / 60) / 24) % 365;
    years = ((((seconds / 60) / 60) / 24) / 365);

    return @{
            @"minutes" : @(minutes),
            @"hours" : @(hours),
            @"days" : @(days),
            @"years" : @(years)
    };
}

/**
* Utility method to convert now's DateTime to hex format
*
* @return Array containing Time and Date Strings representing the date/time now
*/
+(NSArray *)convertNowToHex{
    NSDate *now = [NSDate date];
    return [self convertDateTimeToHex:now];
}

/**
*  Converts specified NSDate object to little endian hex representation
*
*  @param date Date to convert to hex date and time
*
*  @return Array containing Time String and Date string
*/
+(NSArray *)convertDateTimeToHex:(NSDate *)date{
    NSMutableArray *returnArray = [NSMutableArray new];

    // Split date into sec/min/hour/year/day/month strings
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ss:mm:HH:yy:dd:MM"];
    NSString *stringFromDate = [formatter stringFromDate:date];

    NSArray *dateComponents = [stringFromDate componentsSeparatedByString:@":"];

    // Loop through and convert all decimal values to hex values
    for (NSString *comp in dateComponents){
        NSMutableString *tempComp = [@"00" mutableCopy];
        [tempComp appendFormat:@"%@", comp];
        NSString *temp = [NYUtilites convertDecimalToHex:@([comp integerValue]) littleEndian:YES];
        [returnArray addObject:temp];
    }

    // Instantiate date and time strings
    NSMutableString *dateString = [NSMutableString new];
    NSMutableString *timeString = [NSMutableString new];

    // Build date and time strings
    for (NSUInteger dateTime = 0; dateTime < 6; dateTime++) {
        if (dateTime < 3)
            [timeString appendFormat:@"%@", returnArray[dateTime]];
        else
            [dateString appendFormat:@"%@", returnArray[dateTime]];
    }

    // Append null byte to the end
    [dateString appendString:@"00"];
    [timeString appendString:@"00"];

    // Return in time/date array
    return @[timeString, dateString];
}

/**
* Neat utility to substring without all the NSMakeRange
*
* @return Substring from from to to
*/
+(NSString *)substring:(NSString *)string From:(NSUInteger)from length:(NSUInteger)to{
    return [string substringWithRange:NSMakeRange(from, to)];
//    return [[string substringFromIndex:from] substringToIndex:to - from];
}

/**
 * Divides a value by the appropriate multiplier.  This must be done
 * to convert the ui value of a field to the device value.
 *
 * @param value The value to divide
 * @param address The address of the field
 * @param index The index of the current tab
 *
 * @return The converted value to store in the device
 */
+ (NSDecimalNumber *)divideValue:(NSDecimalNumber *)valueFloat
                      forAddress:(NSString *)address
                        forIndex:(int)index{
    NSDecimalNumber *result;
    DataField *dataField;
    AppDelegate *appDelegate;
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    dataField = [[appDelegate getDataModelForIndex:index] retrieveDataFieldForAddress:address];
    
    NSDecimalNumber *multiplier = [dataField multiplier];
    
    if([multiplier isEqualToNumber:@0])
        multiplier = [NSDecimalNumber decimalNumberWithString:@"1.0"];
    
    result = [valueFloat decimalNumberByDividingBy:multiplier];
    
    return result;
}

/**
 * Determines if a given value falls within the valid range for a field.
 *
 * @param value The value to divide
 * @param address The address of the field
 * @param index The index of the current tab
 *
 * @return YES if the given value is valid; NO otherwise
 */
+ (BOOL)checkBoundsForValue:(float)valueFloat
                 forAddress:(NSString *)address
                   forIndex:(int)index {
    
    BOOL result;
    DataField *dataField;
    AppDelegate *appDelegate;
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    dataField = [[appDelegate getDataModelForIndex:index] retrieveDataFieldForAddress:address];
    
    //Copied from APISelectors:
    //Calculate the range if it's under or over voltage values
    if([[dataField address] integerValue] == 59){//59 is Over Voltage Level
        DriveModel *dm = [DriveModel sharedManager];
        
        [dataField setDataRange:[[NSMutableArray alloc] initWithArray:[dm calculateMinMaxForVoltage:2]]];
    }
    else if([[dataField address] integerValue] == 65){ //65 is Under Voltage Level
        DriveModel *dm = [DriveModel sharedManager];
        [dataField setDataRange:[[NSMutableArray alloc] initWithArray:[dm calculateMinMaxForVoltage:1]]];
    }
    
    // check bounds prior to display
    NSMutableArray *dataRange = [dataField dataRange];
    
    // if data is less than minimum or greater than maximum data range, we have a problem
    if([dataRange count] >= 2 &&
       (valueFloat < [[dataRange objectAtIndex:0] floatValue] ||
        valueFloat > [[dataRange objectAtIndex:1] floatValue])){
           result = NO;
    }
    else{
        result = YES;
    }
    
    return result;
}

+ (BOOL)canWrite:(DataField *)dataField {
    BOOL canWrite;
    
    if([[dataField readWrite] isEqualToString:READ_ONLY]){
        canWrite = NO;
    }
    else{
        canWrite = YES;
    }
    
    return canWrite;
}

+ (NSMutableString *)stringFromHexString:(NSString *)hexString {
    // The hex codes should all be two characters.
    if (([hexString length] % 2) != 0)
        return nil;

    NSMutableString *string = [NSMutableString string];

    for (NSInteger i = 0; i < [hexString length]; i += 2) {

        NSString *hex = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSInteger decimalValue = 0;
        sscanf([hex UTF8String], "%x", &decimalValue);
        [string appendFormat:@"%c", decimalValue];
    }

    NSLog(@"string ---%@",string);
    return string;
}

+(NSString *)formatFirmwareVersion:(NSString *)version{
    version = [NYUtilites padString:version padWith:@"0" totalLength:6 padLeft:YES];
    version = [NSString stringWithFormat:@"%@.%@.%@", [NYUtilites substring:version From:0 length:2], [NYUtilites substring:version From:2 length:2], [NYUtilites substring:version From:4 length:2]];
    return version;
}

/**
 * Writes a string to a csv file in a temporary directory
 * and returns the NSURL of the file
 *
 * @param data The string to write to a file
 *
 * @return The location of the file in the file system
 */
+ (NSURL *)writeStringToFile:(NSString *)data{
    // write the string to a file
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:@"logs"] URLByAppendingPathExtension:@"csv"];
    
    NSError *error;
    bool didWrite = [data writeToFile:[fileURL path] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if(!didWrite){
        fileURL = nil;
    }
    
    return fileURL;
}

+(NSString *)calculateCRC:(NSString *)dataString{

    // CRC Table from FCS in Oregon
    unsigned int _CRC32_VALS[256] = {
            0x00000000, 0x77073096, 0xee0e612c, 0x990951ba,
            0x076dc419, 0x706af48f, 0xe963a535, 0x9e6495a3,
            0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988,
            0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91,
            0x1db71064, 0x6ab020f2, 0xf3b97148, 0x84be41de,
            0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
            0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec,
            0x14015c4f, 0x63066cd9, 0xfa0f3d63, 0x8d080df5,
            0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172,
            0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b,
            0x35b5a8fa, 0x42b2986c, 0xdbbbc9d6, 0xacbcf940,
            0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
            0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116,
            0x21b4f4b5, 0x56b3c423, 0xcfba9599, 0xb8bda50f,
            0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924,
            0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,
            0x76dc4190, 0x01db7106, 0x98d220bc, 0xefd5102a,
            0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
            0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818,
            0x7f6a0dbb, 0x086d3d2d, 0x91646c97, 0xe6635c01,
            0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e,
            0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457,
            0x65b0d9c6, 0x12b7e950, 0x8bbeb8ea, 0xfcb9887c,
            0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
            0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2,
            0x4adfa541, 0x3dd895d7, 0xa4d1c46d, 0xd3d6f4fb,
            0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0,
            0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9,
            0x5005713c, 0x270241aa, 0xbe0b1010, 0xc90c2086,
            0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
            0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4,
            0x59b33d17, 0x2eb40d81, 0xb7bd5c3b, 0xc0ba6cad,
            0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a,
            0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683,
            0xe3630b12, 0x94643b84, 0x0d6d6a3e, 0x7a6a5aa8,
            0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
            0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe,
            0xf762575d, 0x806567cb, 0x196c3671, 0x6e6b06e7,
            0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc,
            0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5,
            0xd6d6a3e8, 0xa1d1937e, 0x38d8c2c4, 0x4fdff252,
            0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
            0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60,
            0xdf60efc3, 0xa867df55, 0x316e8eef, 0x4669be79,
            0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236,
            0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f,
            0xc5ba3bbe, 0xb2bd0b28, 0x2bb45a92, 0x5cb36a04,
            0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
            0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a,
            0x9c0906a9, 0xeb0e363f, 0x72076785, 0x05005713,
            0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38,
            0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21,
            0x86d3d2d4, 0xf1d4e242, 0x68ddb3f8, 0x1fda836e,
            0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
            0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c,
            0x8f659eff, 0xf862ae69, 0x616bffd3, 0x166ccf45,
            0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2,
            0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db,
            0xaed16a4a, 0xd9d65adc, 0x40df0b66, 0x37d83bf0,
            0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
            0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6,
            0xbad03605, 0xcdd70693, 0x54de5729, 0x23d967bf,
            0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94,
            0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d};

    // Set starting CRC value
    unsigned long crc = 0xFFFFFFFF;

    // Set up other variables
    char *pDataString = calloc([dataString length], sizeof(char));
    strcpy(pDataString, [dataString UTF8String]);

    char unsigned data[(strlen(pDataString) / 2 - 4)];
    int temp;

    // Loop through all bytes
    for (int first = 0; first < strlen(pDataString) - 8; first += 2) {
        sscanf(&pDataString[first], "%02x", &temp);
        data[first / 2] = temp;
    }

    free(pDataString);

    // Calculate CRC from hex data
    for(int i = 0; i < sizeof(data)/sizeof(data[0]); i++){
        crc = _CRC32_VALS[data[i] ^ (crc & 0xff)] ^ (crc >> 8);
    }

    // Set for new firmware, comment out for old firmware
    crc = ~crc;

    // Set CRC in _data with little endian format
    char c[16];
    sprintf(c, "%16lx", crc);
    NSString *crcHex = [NSString stringWithFormat:@"%16lx", crc];

    // For 32-bit devices, for some reason they translate the '0' to ' '
    crcHex = [crcHex stringByReplacingOccurrencesOfString:@" " withString:@"0"];

    return [crcHex substringWithRange:NSMakeRange(8, 8)];
}

+ (NSArray *)reversedArray:(NSArray *)reverse {
    return [[reverse reverseObjectEnumerator] allObjects];
}
/**
 *  Removes decimal places from decimal without rounding the value
 *
 *  @param stringToConvert The decimal string that needs to be converted
 *  @param decimalPlaces   The number of decimal places you want the string to have
 *
 *  @return NSString of the formatted decimal value
 */
//+ (NSString *) limitDecimalStringWithoutRoundingWithString: (NSString*)stringToConvert withDecimalPlaces: (int)decimalPlaces{
//    NSString *returnString = stringToConvert;
//    
//    //Split the string and remove the decimal places then re-append the string
//    NSArray *splitStringArray = [stringToConvert componentsSeparatedByString:@"."];
//    if([splitStringArray count]>1){
//        if(decimalPlaces > 0)
//            returnString = [NSString stringWithFormat:@"%@.%@", splitStringArray[0], [splitStringArray[1] substringWithRange:NSMakeRange(0, decimalPlaces)]];
//        else
//            returnString = splitStringArray[0];
//    }
//    return returnString;
//}

@end
