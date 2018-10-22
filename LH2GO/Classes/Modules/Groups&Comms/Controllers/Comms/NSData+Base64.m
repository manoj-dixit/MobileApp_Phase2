//
//  NSData+Base64.m
//
// Derived from http://colloquy.info/project/browser/trunk/NSDataAdditions.h?rev=1576
// Created by khammond on Mon Oct 29 2001.
// Formatted by Timothy Hatcher on Sun Jul 4 2004.
// Copyright (c) 2001 Kyle Hammond. All rights reserved.
// Original development by Dave Winer.
//

#import "NSData+Base64.h"

#import <Foundation/Foundation.h>

static char encodingTable[64] = {
		'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
		'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
		'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
		'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };

@implementation NSData (Base64)

+ (id)sharedManager {
    static NSData *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}



+ (NSData *) dataWithBase64EncodedString:(NSString *) string {
	NSData *result = [[NSData alloc] initWithBase64EncodedString:string];
	return result;
}

- (id) initWithBase64EncodedString:(NSString *) string {
	NSMutableData *mutableData = nil;

	if( string ) {
		unsigned long ixtext = 0;
		unsigned long lentext = 0;
		unsigned char ch = 0;
		unsigned char inbuf[3], outbuf[4];
		short i = 0, ixinbuf = 0;
		BOOL flignore = NO;
		BOOL flendtext = NO;
		NSData *base64Data = nil;
		const unsigned char *base64Bytes = nil;

		// Convert the string to ASCII data.
		base64Data = [string dataUsingEncoding:NSASCIIStringEncoding];
		base64Bytes = [base64Data bytes];
		mutableData = [NSMutableData dataWithCapacity:[base64Data length]];
		lentext = [base64Data length];

		while( YES ) {
			if( ixtext >= lentext ) break;
			ch = base64Bytes[ixtext++];
			flignore = NO;

			if( ( ch >= 'A' ) && ( ch <= 'Z' ) ) ch = ch - 'A';
			else if( ( ch >= 'a' ) && ( ch <= 'z' ) ) ch = ch - 'a' + 26;
			else if( ( ch >= '0' ) && ( ch <= '9' ) ) ch = ch - '0' + 52;
			else if( ch == '+' ) ch = 62;
			else if( ch == '=' ) flendtext = YES;
			else if( ch == '/' ) ch = 63;
			else flignore = YES; 
   
			if( ! flignore ) {
				short ctcharsinbuf = 3;
				BOOL flbreak = NO;

				if( flendtext ) {
					if( ! ixinbuf ) break;
					if( ( ixinbuf == 1 ) || ( ixinbuf == 2 ) ) ctcharsinbuf = 1;
					else ctcharsinbuf = 2;
					ixinbuf = 3;
					flbreak = YES;
				}

				inbuf [ixinbuf++] = ch;

				if( ixinbuf == 4 ) {
					ixinbuf = 0;
					outbuf [0] = ( inbuf[0] << 2 ) | ( ( inbuf[1] & 0x30) >> 4 );
					outbuf [1] = ( ( inbuf[1] & 0x0F ) << 4 ) | ( ( inbuf[2] & 0x3C ) >> 2 );
					outbuf [2] = ( ( inbuf[2] & 0x03 ) << 6 ) | ( inbuf[3] & 0x3F );

					for( i = 0; i < ctcharsinbuf; i++ ) 
						[mutableData appendBytes:&outbuf[i] length:1];
				}

				if( flbreak )  break;
			}
		}
	}

	self = [self initWithData:mutableData];
	return self;
}

- (NSString *) base64EncodingWithLineLength:(unsigned int) lineLength {
	const unsigned char	*bytes = [self bytes];
	NSMutableString *result = [NSMutableString stringWithCapacity:[self length]];
	unsigned long ixtext = 0;
	unsigned long lentext = [self length];
	long ctremaining = 0;
	unsigned char inbuf[3], outbuf[4];
	short i = 0;
	short charsonline = 0, ctcopy = 0;
	unsigned long ix = 0;

	while( YES ) {
		ctremaining = lentext - ixtext;
		if( ctremaining <= 0 ) break;

		for( i = 0; i < 3; i++ ) {
			ix = ixtext + i;
			if( ix < lentext ) inbuf[i] = bytes[ix];
			else inbuf [i] = 0;
		}

		outbuf [0] = (inbuf [0] & 0xFC) >> 2;
		outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
		outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
		outbuf [3] = inbuf [2] & 0x3F;
		ctcopy = 4;

		switch( ctremaining ) {
		case 1: 
			ctcopy = 2; 
			break;
		case 2: 
			ctcopy = 3; 
			break;
		}

		for( i = 0; i < ctcopy; i++ )
			[result appendFormat:@"%c", encodingTable[outbuf[i]]];

		for( i = ctcopy; i < 4; i++ )
			[result appendFormat:@"%c",'='];

		ixtext += 3;
		charsonline += 4;

		if( lineLength > 0 ) {
			if (charsonline >= lineLength) {
				charsonline = 0;
				[result appendString:@"\n"];
			}
		}
	}

	return result;
}



//
//+ (NSData *)dataFromBase64String:(NSString *)aString
//{
//    NSData *data = [aString dataUsingEncoding:NSASCIIStringEncoding];
//    size_t outputLength;
//    void *outputBuffer = NewBase64Decode([data bytes], [data length], &outputLength);
//    NSData *result = [NSData dataWithBytes:outputBuffer length:outputLength];
//    free(outputBuffer);
//    return result;
//}
//
//#define xx 65
//static unsigned char base64DecodeLookup[256] =
//{
//    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
//    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
//    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 62, xx, xx, xx, 63,
//    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, xx, xx, xx, xx, xx, xx,
//    xx,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
//    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, xx, xx, xx, xx, xx,
//    xx, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
//    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, xx, xx, xx, xx, xx,
//    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
//    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
//    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
//    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
//    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
//    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
//    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
//    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
//};
//
//#define BASE64_UNIT_SIZE 4
//#define BINARY_UNIT_SIZE 3
//
//void *NewBase64Decode(
//                      const char *inputBuffer,
//                      size_t length,
//                      size_t *outputLength)
//{
//    if (length == -1)
//    {
//        length = strlen(inputBuffer);
//    }
//    
//    size_t outputBufferSize =
//    ((length+BASE64_UNIT_SIZE-1) / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE;
//    unsigned char *outputBuffer = (unsigned char *)malloc(outputBufferSize);
//    
//    size_t i = 0;
//    size_t j = 0;
//    while (i < length)
//    {
//        //
//        // Accumulate 4 valid characters (ignore everything else)
//        //
//        unsigned char accumulated[BASE64_UNIT_SIZE];
//        size_t accumulateIndex = 0;
//        while (i < length)
//        {
//            unsigned char decode = base64DecodeLookup[inputBuffer[i++]];
//            if (decode != xx)
//            {
//                accumulated[accumulateIndex] = decode;
//                accumulateIndex++;
//                
//                if (accumulateIndex == BASE64_UNIT_SIZE)
//                {
//                    break;
//                }
//            }
//        }
//        
//        //
//        // Store the 6 bits from each of the 4 characters as 3 bytes
//        //
//        // (Uses improved bounds checking suggested by Alexandre Colucci)
//        //
//        if(accumulateIndex >= 2)
//            outputBuffer[j] = (accumulated[0] << 2) | (accumulated[1] >> 4);
//        if(accumulateIndex >= 3)  
//            outputBuffer[j + 1] = (accumulated[1] << 4) | (accumulated[2] >> 2);  
//        if(accumulateIndex >= 4)  
//            outputBuffer[j + 2] = (accumulated[2] << 6) | accumulated[3];
//        j += accumulateIndex - 1;
//    }
//    
//    if (outputLength)
//    {
//        *outputLength = j;
//    }
//    return outputBuffer;
//}



@end