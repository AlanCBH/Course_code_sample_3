#include "declarations.h"

void
t1(float *restrict A, float *restrict B) {
    for (int nl = 0; nl < 1000000; nl ++) {
        #pragma clang loop vectorize(enable)
        for (int i = 0; i < LEN1; i += 2) {
            A[i + 1] = (A[i] + B[i]) / (A[i] + B[i] + 1.);
            //A[i + 3] = (A[i+2] + B[i+2]) / (A[i+2] + B[i+2] + 1.);
            //A[i + 5] = (A[i+4] + B[i+4]) / (A[i+4] + B[i+4] + 1.);
            //A[i + 7] = (A[i+6] + B[i+6]) / (A[i+6] + B[i+6] + 1.);
        }
        B[0] ++;
    }
}
