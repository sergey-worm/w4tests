//##################################################################################################
//
//  hello - simple app example.
//
//##################################################################################################

#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include "l4_types.h"
#include "wrm_log.h"
#include "wrm_thr.h"
#include "wrm_mpool.h"
#include "wlibc_panic.h"

enum
{
	Force = 1,  // force termination test
	Self  = 2,  // self termination test
};

static long thread_func(long sleep_ms)
{
	wrm_logi("hello\n");
	usleep(sleep_ms * 1000);
	return 123;
}

void test_thread_termination(int test_type, unsigned tests, unsigned threads_per_test)
{
	wrm_logi("-----------------------------------------------------\n");
	wrm_logi("--  %s termination, tests=%u, threads=%u\n", test_type==Force?"force":"self",
		tests, threads_per_test);
	wrm_logi("-----------------------------------------------------\n");

	L4_thrid_t ids[40];
	if (threads_per_test > sizeof(ids)/sizeof(ids[0]))
		panic("%s:  too big threads_per_test=%u.\n", __func__, threads_per_test);

	// force deletion of thread
	for (unsigned i=0; i<tests; ++i)
	{
		// configure for force- or self-termination
		int loc_msleep = test_type == Force ? 0 : 10*threads_per_test;
		int rem_msleep = test_type == Force ? 10*threads_per_test : 0;
		int expect_state = test_type == Force ? Wrm_thr_state_busy : Wrm_thr_state_done;
		int expect_tcode = test_type == Force ? i : 123;

		for (unsigned j=0; j<threads_per_test; ++j)
		{
			// alloc memory
			//wrm_logi("test=%02u:  alloc memory  ...\n", i);
			L4_fpage_t stack_fp = wrm_pgpool_alloc(Cfg_page_sz);
			L4_fpage_t utcb_fp = wrm_pgpool_alloc(Cfg_page_sz);
			wrm_logi("test=%02u:  alloc memory  stack=0x%lx, utcb=0x%lx.\n", i, stack_fp.addr(), utcb_fp.addr());
			assert(!stack_fp.is_nil());
			assert(!utcb_fp.is_nil());

			// create
			char name[8];
			sprintf(name, "t-%0u", j);
			//wrm_logi("test=%02u:  create thread ...\n", i);
			int rc = wrm_thr_create(utcb_fp, thread_func, rem_msleep, stack_fp.addr(), stack_fp.size(),
			                        255, name, Wrm_thr_flag_no, &ids[j]);
			wrm_logi("test=%02u:  create thread - rc=%d, id=%u.\n", i, rc, ids[j].number());
			assert(!rc && "wrm_thr_create() - failed");
		}

		usleep(loc_msleep * 1000);

		for (unsigned j=0; j<threads_per_test; ++j)
		{
			// delete
			//wrm_logi("test=%02u:  delete thread ...\n", i);
			long term_code = i;
			int term_state;
			L4_fpage_t utcb;
			addr_t stack;
			size_t stack_sz;
			int rc = wrm_thr_delete(ids[j], &term_code, &term_state, &utcb, &stack, &stack_sz);
			wrm_logi("test=%02u:  delete thread - rc=%d, id=%u, stack=0x%lx/0x%zx, utcb=0x%lx, tcode=%ld, tstate=%d.\n",
				i, rc, ids[j].number(), stack, stack_sz, utcb.addr(), term_code, term_state);
			assert(!rc && "wrm_thr_delete() - failed");
			assert(term_state == expect_state);
			assert(term_code == expect_tcode);

			// free memory
			wrm_pgpool_add(utcb);
			wrm_pgpool_add(L4_fpage_t::create(stack, stack_sz, Acc_rw));
		}
	}
}

int main(int argc, const char* argv[])
{
	wrm_logi("[test]  hello.\n");

	//                      type   tests  threads
	test_thread_termination(Force, 1000,   1);
	test_thread_termination(Self,  1000,   1);
	test_thread_termination(Force,  500,   2);
	test_thread_termination(Self,   500,   2);
	test_thread_termination(Force,  100,  16);
	test_thread_termination(Self,   100,  16);

	printf("[test]  test passed.\n");
	return 0;
}
