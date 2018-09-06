/**
 * @file
 * Contains an implementation of the extractMessage function.
 */

#include <iostream> // might be useful for debugging
#include <assert.h>
#include "extractMessage.h"

using namespace std;

char *extractMessage(const char *message_in, int length) {
   // Length must be a multiple of 8
   assert((length % 8) == 0);

   // allocates an array for the output
   char *message_out = new char[length];
   for (int i=0; i<length; i++) {
   		message_out[i] = 0;    // Initialize all elements to zero.
	}

	// TODO: write your code here
	int out = 0;
	for (int ii = 0; ii < length; ii=ii+8) {
	   for (int j = 0; j < 8; j++) {
		 out = 0;
		unsigned char temp = 1;
		temp = temp<<j;
	  	 for (int k = 0; k < 8; k++) {
			unsigned char temp2 = (message_in[ii+k]&temp);			
			if (int(temp2) > 0) {
			  int sum = 1;
			  for (int n = 0;n<k;n++) {
				sum = sum*2;	
				}
			  out += sum;
			}
		}
			
			message_out[ii+j] = char(out);
		}
	
	}
	return message_out;
}
