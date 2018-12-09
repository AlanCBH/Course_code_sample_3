#include "declarations.h"

void
t5(float *restrict A, float *restrict B, float *restrict C, float *restrict D, float *restrict E) {
    for (int nl = 0; nl < ntimes; nl ++) {
        #pragma clang loop vectorize(enable) distribute(enable)
        // for (int i = 1; i < LEN5; i ++) {
        //     A[i] = D[i - 1] + (float) sqrt(C[i]);
        //     D[i] = B[i] + (float) sqrt(E[i]);
        // }
        for (int i = 1; i < LEN5; i ++) {

            D[i] = B[i] + (float) sqrt(E[i]);
            A[i] = D[i - 1] + (float) sqrt(C[i]);
            //A[i+1] = D[i] + (float)sqrt(C[i+1]);
            //D[i+1] = B[i+1] + (float) sqrt(E[i+1]);
        }
        A[0] ++;
    }
}
