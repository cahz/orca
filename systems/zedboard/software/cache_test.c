#include "cache_test.h"

/* For this test, the cache size should be set to 256 bytes,
 * the cache line size should be set to 12 bytes, as well as the TCRAM size should 
 * be set to 64 bytes.
 */

void cache_test(void) __attribute__((section(".cache_test_1"))) {

}
