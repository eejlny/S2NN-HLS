#ifndef _SNN_ENV_H_
#define _SNN_ENV_H_

/* Run types */
#define TYPE_HLS					0
#define TYPE_ZYNQ					1
#define TYPE_SW_APP					2

/* Precision types */
#define FIXED_POINT					0	// FPGA_CLK =  8ns (HLS CLK: 7ns, Estimated: 6.38ns)
#define FLOATING_POINT				1	// FPGA_CLK = 10ns (HLS CLK: 9ns, Estimated: 8.42ns)

/* Results types */
#define RESULTS_NONE				0
#define RESULTS_FILE				1
#define RESULTS_STDOUT				2

/* App type */
#define APP_RANDOM					0
#define APP_XOR						1
#define APP_ADDER					2
#define APP_PATTERN					3
#define APP_SINGLE					4

#endif /* _SNN_ENV_H_ */
