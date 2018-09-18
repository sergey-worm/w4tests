//##################################################################################################
//
//  hello - simple app example.
//
//##################################################################################################

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>
#include <assert.h>
#include "wrm_log.h"


int main(int argc, const char* argv[])
{
	wrm_logi("[test]  hello.\n");

	enum
	{
		Tests = 20*1000*1000,
		Spectr_points = sizeof(int) * 100,
		Spectr_step   = RAND_MAX / Spectr_points,
		Expect_hits   = Tests / Spectr_points
	};

	wrm_logi("[test]  RAND_MAX:       %d.\n", RAND_MAX);
	wrm_logi("[test]  INT_MAX:        %d.\n", INT_MAX);
	wrm_logi("[test]  Spectr_points:  %d.\n", Spectr_points);
	wrm_logi("[test]  Spectr_step     %d.\n", Spectr_step);
	wrm_logi("[test]  Expect_hits     %d.\n", Expect_hits);

	unsigned hits [Spectr_points];
	memset(hits, 0, sizeof(hits));

	srand(1234);

	for (unsigned i=0; i<Tests; ++i)
	{
		int val = rand();
		//wrm_logd("  val=%d.\n", val);

		// mark in hits
		for (int i=Spectr_points-1; i>=0; --i)
		{
			if (val > (i * Spectr_step))
			{
				hits[i]++;
				break;
			}
		}
	}

	int warnings = 0;
	unsigned tests = 0;
	for (unsigned i=0; i<Spectr_points; ++i)
	{
		wrm_logi("[test]  %10u  ...  %u.\n", i * Spectr_step, hits[i]);
		tests += hits[i];
		if (hits[i] < Expect_hits*0.98  ||  hits[i] > Expect_hits*1.02)  // allowed deviation 2%
			warnings++;
	}
	assert(tests == Tests);
	wrm_logi("[test]  tests=%u.\n", tests);
	if (warnings)
	{
		wrm_loge("[test]  watnings=%u.\n", warnings);
		wrm_loge("[test]  test failed.\n");
	}
	else
	{
		wrm_logi("[test]  test passed.\n");
	}
	return 0;
}
