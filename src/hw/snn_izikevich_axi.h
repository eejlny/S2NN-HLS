#ifndef _SNN_IZIKEVICH_AXI_H_
#define _SNN_IZIKEVICH_AXI_H_

#include "../common/snn_types.h"

void axis_cp_network_to_mem(
			hls_stream_64_t& input_stream,
			uint1_t neuron_type[NEURONS_PER_LAYER][NEURONS_PER_LAYER]) {

	int32_t b, y, l, s;
	ap_uint<AXI_SIZE> bits;
	y = 0; l = 0;

	// Store neuron_type from stream
	for (s = 0; s < AXI_NEURON_TYPE_LENGTH; s++) for (b = 0; b < AXI_SIZE; b++) {
		#pragma HLS PIPELINE II=2

		// Get 64-bit data from stream
		if (b == 0) {
			axis64_t data_in = input_stream.read();
			bits = ap_uint<AXI_SIZE>(data_in.data);
		}

		// Store data into memory
		if (l < NUMBER_OF_LAYERS)
			neuron_type[l][y] = bits[b];

		// Handle 2-dimensional indices
		if (y < NEURONS_PER_LAYER - 1) { y ++; } else { y = 0; l++;}
	}
	return;
}

void axis_cp_inputs_to_mem(
			uint32_t p_input[AXI_INPUT_LENGTH],
			uint1_t p[INPUT_SYNAPSES]) {

	int32_t x, b, stream_id;
	ap_uint<AXIL_SIZE> bits = 0;

	// Get neuron_type stream
	for (stream_id = 0; stream_id < AXI_INPUT_LENGTH; stream_id++) {
		for (b = 0; b < AXIL_SIZE; b++) {

			#pragma HLS PIPELINE II=2
			x = stream_id * AXIL_SIZE + b;

			// Get new 32-bit data
			if (b == 0) {
				bits = ap_uint<AXIL_SIZE>(p_input[stream_id]);
			}

			// Store data into memory
			if (x < INPUT_SYNAPSES) p[x] = bits[b];
		}
	}
	return;
}

void axis_cp_output_to_stream(
			hls_stream_64_t& output_stream,
			vu_dat_t 	v[NUMBER_OF_NEURONS],
			uint32_t 	output_indexes_mem[AXI_POTENTIAL_OUTPUTS],
			ap_uint<AXI_SIZE>firings_mem[AXI_FIRINGS_LENGTH]) {
	// Set output stream
	uint32_t stream_id, x, axi_idx;

	// Potential outputs
	potential_outputs: for (stream_id = 0, x = 0; stream_id < AXI_POTENTIAL_OUTPUT_LENGTH; stream_id++, x+=2) {
		axis64_t data_out;
		#if PRECISION_TYPE == FIXED_POINT
		data_out.data = float32_to_uint64(v[output_indexes_mem[x]].to_float(), v[output_indexes_mem[x + 1]].to_float());
		#elif PRECISION_TYPE == FLOATING_POINT
		data_out.data = float32_to_uint64(v[output_indexes_mem[x]], v[output_indexes_mem[x + 1]]);
		#endif
		data_out.last = 0;
		output_stream.write(data_out);
	}

	// Set output stream
	firing_outputs: for (stream_id = 0; stream_id < AXI_FIRINGS_LENGTH; stream_id++) {
		// Store data
		axis64_t data_out;
		data_out.data = firings_mem[stream_id].to_uint64();
		data_out.last = (stream_id >= (AXI_FIRINGS_LENGTH - 1) ? 1 : 0);
		output_stream.write(data_out);
	}
	return;
}

#endif /* _SNN_IZIKEVICH_AXI_H_ */
