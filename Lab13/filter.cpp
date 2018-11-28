#include <stdio.h>
#include <stdlib.h>
#include "filter.h"

// modify this code by fusing loops together
void
filter_fusion(pixel_t **image1, pixel_t **image2) {
/////////////////////////////////////////////////////

    // for (int i = 1; i < SIZE - 1; i ++) {
    //     filter1(image1, image2, i);
    //
    // }
/////////////////////////////////////////////////////
    // for (int i = 2; i < SIZE - 2; i ++) {
    //     filter1(image1, image2, i);
    //     filter2(image1, image2, i);
    // }

     filter1(image1, image2, 1);
     filter1(image1, image2, 2);
     filter1(image1, image2, 3);
     filter1(image1, image2, 4);
     filter1(image1, image2, 5);
    for (int i = 1; i < SIZE - 6; i ++) {
             //ensure image2[i]
         filter1(image1, image2, i+5);    //ensure image2[i+5]
         filter2(image1, image2, i+1);

         filter3(image2, i);
     }
     filter2(image1, image2, SIZE-3);
     filter2(image1, image2, SIZE-4);
     filter2(image1, image2, SIZE-5);
     filter3(image2, SIZE-6);
    // for (int i = 1; i < SIZE - 5; i ++) {
    //     filter1(image1, image2, i);
    //     filter2(image1, image2, i+1);
    //
    //     filter3(image2, i);
    // }
    // filter1(image1, image2, SIZE-2);
    // filter1(image1, image2, SIZE-3);
    // filter1(image1, image2, SIZE-4);
    // filter1(image1, image2, SIZE-5);
    //
    // filter2(image1, image2, SIZE-3);
    // filter2(image1, image2, SIZE-4);
}

// modify this code by adding software prefetching
void
filter_prefetch(pixel_t **image1, pixel_t **image2) {
        int iter_Ahead = 32;
    for (int i = 1; i < SIZE - 1; i ++) {
        filter1(image1, image2, i);
        __builtin_prefetch(image1[i+iter_Ahead], 0, 3);
        __builtin_prefetch(image2[i+iter_Ahead], 1, 1);
    }

    for (int i = 2; i < SIZE - 2; i ++) {
        filter2(image1, image2, i);
        __builtin_prefetch(image1[i+iter_Ahead], 0, 3);
        __builtin_prefetch(image2[i+iter_Ahead], 1, 1);
    }

    for (int i = 1; i < SIZE - 5; i ++) {
        filter3(image2, i);
        __builtin_prefetch(image2[i+iter_Ahead], 1, 3);
    }
}

// modify this code by adding software prefetching and fusing loops together
void
filter_all(pixel_t **image1, pixel_t **image2) {
    // for (int i = 1; i < SIZE - 1; i ++) {
    //     filter1(image1, image2, i);
    // }
    //
    // for (int i = 2; i < SIZE - 2; i ++) {
    //     filter2(image1, image2, i);
    // }
    //
    // for (int i = 1; i < SIZE - 5; i ++) {
    //     filter3(image2, i);
    // }
    filter1(image1, image2, 1);
    filter1(image1, image2, 2);
    filter1(image1, image2, 3);
    filter1(image1, image2, 4);
    filter1(image1, image2, 5);
    int iter_Ahead = 16;
   for (int i = 1; i < SIZE - 6; i ++) {
            //ensure image2[i]
        filter1(image1, image2, i+5);    //ensure image2[i+5]
        filter2(image1, image2, i+1);

        filter3(image2, i);
        __builtin_prefetch(image1[i+5+iter_Ahead], 0, 3);
        __builtin_prefetch(image2[i+5+iter_Ahead], 1, 3);
    }
    filter2(image1, image2, SIZE-3);
    filter2(image1, image2, SIZE-4);
    filter2(image1, image2, SIZE-5);
    filter3(image2, SIZE-6);
}
