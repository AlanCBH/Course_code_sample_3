#include "mandelbrot.h"
#include <xmmintrin.h>

// cubic_mandelbrot() takes an array of SIZE (x,y) coordinates --- these are
// actually complex numbers x + yi, but we can view them as points on a plane.
// It then executes 200 iterations of f, using the <x,y> point, and checks
// the magnitude of the result; if the magnitude is over 2.0, it assumes
// that the function will diverge to infinity.

// vectorize the code below using SIMD intrinsics
int *
cubic_mandelbrot_vector(float x[SIZE], float y[SIZE]) {
    static int ret[SIZE];
    //float x1, y1, x2, y2;
    __m128 accx,accy,accx_new,accy_new;
    for (int i = 0; i < SIZE; i += 4) {
        //x1 = y1 = 0.0;
        accx = _mm_set1_ps(0.0);
        accy = _mm_set1_ps(0.0);
        // Run M_ITER iterations
        for (int j = 0; j < M_ITER; j ++) {
            // Calculate x1^2 and y1^2
            //float x1_squared = x1 * x1;
            //float y1_squared = y1 * y1;
            __m128 x_squared = _mm_mul_ps(accx,accx);
            __m128 y_squared = _mm_mul_ps(accy,accy);
            // Calculate the real piece of (x1 + (y1*i))^3 + (x + (y*i))
            //x2 = x1 * (x_squared - 3 * y_squared) + x[i];

            __m128 factor = _mm_set1_ps(3.0);
            accx_new = _mm_sub_ps(x_squared,_mm_mul_ps(y_squared,factor));
            accx_new = _mm_add_ps(_mm_mul_ps(accx,accx_new),_mm_loadu_ps(&x[i]));
            // Calculate the imaginary portion of (x1 + (y1*i))^3 + (x + (y*i))
            //y2 = y1 * (3 * x1_squared - y1_squared) + y[i];
            accy_new = _mm_sub_ps(_mm_mul_ps(x_squared,factor),y_squared);
            accy_new = _mm_add_ps(_mm_mul_ps(accy,accy_new),_mm_loadu_ps(&y[i]));
            // Use the resulting complex number as the input for the next
            // iteration
            accx = accx_new;
            accy = accy_new;
        }

        // caculate the magnitude of the result;
        // we could take the square root, but we instead just
        // compare squares
        float temp[4];
        __m128 comp = _mm_set1_ps(4.0);
        __m128 res = _mm_add_ps(_mm_mul_ps(accx_new,accx_new),_mm_mul_ps(accy_new,accy_new));
        _mm_storeu_ps(temp,_mm_cmplt_ps(res,comp));
        ret[i] = temp[0];
        ret[1+i] = temp[1];
        ret[2+i] = temp[2];
        ret[3+i] = temp[3];
        //ret[i] = _mm_loadu_ps(res);
        //ret[i] = ((x2 * x2) + (y2 * y2)) < (M_MAG * M_MAG);
    }

    return ret;
}
