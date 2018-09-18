//##################################################################################################
//
//  hello - simple app example.
//
//##################################################################################################

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include "wrm_log.h"
#include "wrm_mpool.h"
#include "wlibc_panic.h"
#include "wlibc_cb.h"

int main(int argc, const char* argv[])
{
	wrm_logi("[test]  hello.\n");
	wrm_logi("[test]  RAND_MAX=%d.\n", RAND_MAX);

	enum { Tests = 100, Allocs = 100 };
	void* addrs [Allocs];
	memset(addrs, 0, sizeof(addrs));

	wrm_mpool_dump();

	for (unsigned i=0; i<Tests; ++i)
	{
		wrm_logi("[test]  TEST #%d:\n\n", i);
		//wrm_mpool_dump();
		for (unsigned j=0; j<Allocs; ++j)
		{
			int sz = rand() % 100;
			void* p = malloc(sz);
			wrm_logd("  malloc result:  sz=%2d, a=%p.\n", sz, p);
			if (p)
				memset(p, 0, sz);
			else if (sz && !p)
				panic("    wrm_malloc(%d) - failed.\n", sz);
			addrs[j] = p;
		}
		//wrm_mpool_dump();
		for (unsigned j=0; j<Allocs; ++j)
		{
			wrm_logd("  free p=%p.\n", addrs[j]);
			free(addrs[j]);
		}
		//wrm_mpool_dump();
	}

	wrm_mpool_dump();
	wrm_logi("[test]  test passed.\n");
	return 0;
}
