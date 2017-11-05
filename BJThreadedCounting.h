#include <CoreFoundation/CFDate.h>
#include <dispatch/queue.h>
#include <sys/sysctl.h>

// pass number to count up to
// pass 0 to threads to use the amount of cores on the device
// completion includes execution time in seconds
void countOnThreads(const unsigned long long max, unsigned int threads, void (^_Nullable completion)(CFTimeInterval seconds, unsigned long long check, unsigned int threads));
