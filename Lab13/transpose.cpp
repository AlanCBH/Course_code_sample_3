#include <algorithm>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "transpose.h"

// will be useful
// remember that you shouldn't go over SIZE
using std::min;

// modify this function to add tiling
// void
// transpose_tiled(int **src, int **dest) {
//     for (int i = 0; i < SIZE; i ++) {
//         for (int j = 0; j < SIZE; j ++) {
//             dest[i][j] = src[j][i];
//         }
//     }
// }
void
transpose_tiled(int **src, int **dest) {
    for (int i = 0; i < SIZE-3; i += 4) {
        for (int j = 0; j < SIZE-3; j += 4) {


                for (int m = 0; m < 4; m++) {
                        for (int n = 0; n < 4; n++) {
                                int temp = src[i+m][j+n];
                                dest[j+n][i+m] = temp;
                        }
                }

                // dest[j][i] = dest00;
                // dest[j+1][i] = dest10;
                // dest[j][i+1] = dest01;
                // dest[j+1][i+1] = dest10;
        }
    }
    for (int i = 0; i < SIZE; i++) {
            for (int j = 1; j < 4; j++) {
            dest[i][SIZE-j] = src[SIZE-j][i];
            dest[SIZE-j][i] = src[i][SIZE-j];
        }
    }
}
