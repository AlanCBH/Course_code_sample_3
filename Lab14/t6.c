#include "declarations.h"

void
t6(float *restrict A, float *restrict D) {
    for (int nl = 0; nl < ntimes; nl ++) {
        A[0] = 0;
        #pragma clang loop vectorize(assume_safety) interleave_count(8)
        for (int i = 0; i < (LEN6 - 3); i ++) {
            A[i] = D[i] + (float) 1.0;
             //A[i+1] = D[i+1] + (float) 1.0;
              //A[i+2] = D[i+2] + (float) 1.0;
            D[i + 3] = A[i] + (float) 2.0;
             //D[i + 4] = A[i+1] + (float) 2.0;
              //D[i + 5] = A[i+2] + (float) 2.0;
        }
    }
}
