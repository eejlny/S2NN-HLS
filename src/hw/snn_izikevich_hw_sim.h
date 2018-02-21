#ifndef _SNN_IZIKEVICH_HW_SIM_H_
#define _SNN_IZIKEVICH_HW_SIM_H_

#include "stdio.h"
#include "assert.h"
#include "hls_stream.h"
#include "../snn_config.h"
#include "../common/snn_types.h"
#include "../common/snn_network.h"

#define	XST_SUCCESS			0
#define	XST_FAILURE			1

#define STATE_INIT			0
#define STATE_PROCESS		1

#define SUCCESS_OK			1

/*****************************************************************************
 *                                Variables      		                     *
 *****************************************************************************/

uint32_t neurons_to_report[2] = { NEURON_TO_PLOT, NUMBER_OF_NEURONS/4 };

// Flags
volatile uint32_t returnResult;

/*****************************************************************************
 *                                Prototypes    		                     *
 *****************************************************************************/

uint1_t hls_snn_izikevich(uint1_t state, uint32_t* p_input, uint32_t* output_indexes, hls_stream_64_t&,
		hls_stream_64_t&, hls_stream_64_t&, hls_stream_64_t&, hls_stream_64_t&);
static int hw_snn_izikevich_config_network(uint64_t *network_stream, uint64_t *output_stream);
static int hw_snn_izikevich_run_step(uint32_t *input_p, uint64_t weights_stream[AXI_WEIGHTS_PORTS][AXI_WEIGHTS_LENGTH], uint64_t *output_stream);

/*****************************************************************************
 *                            External Functions    		                 *
 *****************************************************************************/

static int hw_snn_izikevich_config_network(uint64_t *network_stream, uint64_t *output_stream) {

	uint32_t *nilptr;
	#ifdef SIM_NATIVE_HLS_STREAM
	hls_stream_64_t hls_input_stream("input_stream");
	hls_stream_64_t hls_null_stream("null_stream");
	hls_stream_64_t hls_output_stream("output_stream");

	for (uint32_t s = 0; s < AXI_NEURON_TYPE_LENGTH; s++) {
		axis64_t data_in;
		data_in.data = network_stream[s];
		data_in.last = ((s >= ((AXI_NEURON_TYPE_LENGTH) - 1)) ? 1 : 0);
		hls_input_stream.write(data_in);
	}
	#else
	uint64_t *nilptr64;
	hls_stream_64_t hls_input_stream(network_stream);
	hls_stream_64_t hls_null_stream(nilptr64);
	hls_stream_64_t hls_output_stream(output_stream);
	#endif

	// Check return result for verification
	returnResult = hls_snn_izikevich(STATE_INIT, nilptr, neurons_to_report, hls_input_stream,
									 hls_null_stream, hls_null_stream, hls_null_stream, hls_output_stream);
	if (returnResult != SUCCESS_OK) {
		printf("HLS ERROR: Expected return result %d and got %ld...\n", SUCCESS_OK, returnResult);
		return XST_FAILURE;
	}

	// Read outputs from stream
	#ifdef SIM_NATIVE_HLS_STREAM
	for (uint32_t s = 0; s < AXI_OUTPUT_LENGTH; s++) {
		axis64_t data_out = hls_output_stream.read();
		output_stream[s] = data_out.data;
	}
	#endif
	return XST_SUCCESS;
}

static int hw_snn_izikevich_run_step(uint32_t *input_p, uint64_t weights_stream[AXI_WEIGHTS_PORTS][AXI_WEIGHTS_LENGTH], uint64_t *output_stream) {

	uint32_t *nilptr;

	#ifdef SIM_NATIVE_HLS_STREAM
	hls_stream_64_t hls_stream0("input_stream0");
	hls_stream_64_t hls_stream1("input_stream1");
	hls_stream_64_t hls_stream2("input_stream2");
	hls_stream_64_t hls_stream3("input_stream3");
	hls_stream_64_t hls_output_stream("output_stream");

	for (uint32_t s = 0; s < AXI_WEIGHTS_LENGTH; s++) {
		ap_uint<1> isLast =  ((s >= (AXI_WEIGHTS_LENGTH - 1)) ? 1 : 0);
		axis64_t data0; data0.data = weights_stream[0][s]; data0.last = isLast; hls_stream0.write(data0);
		axis64_t data1; data1.data = weights_stream[1][s]; data1.last = isLast; hls_stream1.write(data1);
		axis64_t data2; data2.data = weights_stream[2][s]; data2.last = isLast; hls_stream2.write(data2);
		axis64_t data3; data3.data = weights_stream[3][s]; data3.last = isLast; hls_stream3.write(data3);
	}
	assert(hls_stream0.size() == AXI_WEIGHTS_LENGTH);
	assert(hls_stream1.size() == AXI_WEIGHTS_LENGTH);
	assert(hls_stream2.size() == AXI_WEIGHTS_LENGTH);
	assert(hls_stream3.size() == AXI_WEIGHTS_LENGTH);
	#else
	hls_stream_64_t hls_stream0(weights_stream[0]);
	hls_stream_64_t hls_stream1(weights_stream[1]);
	hls_stream_64_t hls_stream2(weights_stream[2]);
	hls_stream_64_t hls_stream3(weights_stream[3]);
	hls_stream_64_t hls_output_stream(output_stream);
	#endif

	// Check return result for verification
	returnResult = hls_snn_izikevich(STATE_PROCESS, input_p, nilptr,
									 hls_stream0, hls_stream1, hls_stream2, hls_stream3, hls_output_stream);
	if (returnResult != SUCCESS_OK) {
		printf("HLS ERROR: Expected return result %d and got %ld...\n", SUCCESS_OK, returnResult);
		return XST_FAILURE;
	}

	// Read outputs from stream
	#ifdef SIM_NATIVE_HLS_STREAM
	assert(hls_output_stream.size() == AXI_OUTPUT_LENGTH);
	for (uint32_t s = 0; s < AXI_OUTPUT_LENGTH; s++) {
		axis64_t data_out = hls_output_stream.read();
		output_stream[s] = data_out.data;
	}
	#endif
	return XST_SUCCESS;
}

#endif /* _SNN_IZIKEVICH_HW_SIM_H_ */
