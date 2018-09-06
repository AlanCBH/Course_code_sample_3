/**
 * @file
 * Contains an implementation of the countOnes function.
 */

unsigned countOnes(unsigned input) {
	// TODO: write your code here
	unsigned char canvas = 255;
	unsigned char in1 = canvas&input;
	input = input>>8;
	unsigned char in2 = canvas&input;
	input = input>>8;
	unsigned char in3 = canvas&input;
	input = input>>8;
	unsigned char in4 = canvas&input;

	canvas = 170; //10101010
	unsigned char in1l = (canvas&in1)>>1;
	unsigned char in2l = (canvas&in2)>>1;
	unsigned char in3l = (canvas&in3)>>1;
	unsigned char in4l = (canvas&in4)>>1;

	canvas = 85; //01010101
	unsigned char in1r = canvas&in1;
	unsigned char in2r = canvas&in2;
	unsigned char in3r = canvas&in3;
	unsigned char in4r = canvas&in4;

	in1 = in1l+in1r;
	in2 = in2l+in2r;
	in3 = in3l+in3r;
	in4 = in4l+in4r;

	canvas = 204;//11001100
	in1l = (canvas&in1)>>2;
	in2l = (canvas&in2)>>2;
	in3l = (canvas&in3)>>2;
  in4l = (canvas&in4)>>2;

	canvas = 51; //00110011
	in1r = canvas&in1;
	in2r = canvas&in2;
	in3r = canvas&in3;
	in4r = canvas&in4;

	in1 = in1l+in1r;
	in2 = in2l+in2r;
	in3 = in3l+in3r;
	in4 = in4l+in4r;

	canvas = 15; //00001111
	in1r = canvas&in1;
	in2r = canvas&in2;
	in3r = canvas&in3;
	in4r = canvas&in4;

	canvas = 240;//11110000
	in1l = (canvas&in1)>>4;
	in2l = (canvas&in2)>>4;
	in3l = (canvas&in3)>>4;
  in4l = (canvas&in4)>>4;

	in1 = in1l+in1r;
	in2 = in2l+in2r;
	in3 = in3l+in3r;
	in4 = in4l+in4r;

	unsigned int res = int(in1+in2+in3+in4);

	return res;
}
