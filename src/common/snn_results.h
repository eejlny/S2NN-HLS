#ifndef _SNN_RESULTS_H_
#define _SNN_RESULTS_H_

// Common libraries
#include <stdio.h>
#include <stdlib.h>
#include "../snn_config.h"
#include "../networks/snn_network_defs.h"

#ifndef PERSIST_APP_RESULTS

#if PERSIST_HW_RESULTS != RESULTS_NONE
void persist_hw_results(uint1_sw_t neuron_type[NUMBER_OF_LAYERS][NEURONS_PER_LAYER], uint64_t *out_stream) {

	int32_t t, x, l, xl;
	#if PERSIST_HW_RESULTS == RESULTS_FILE
	FILE * file1 = fopen("all_neurons_hw.csv", "w");
	FILE * file2 = fopen("firing_rates_hw.csv", "w");
	if (file1 && file2)
	#endif
	{
		int32_t firing_rate[NUMBER_OF_NEURONS];
		for (x = 0; x < NUMBER_OF_NEURONS; x++) firing_rate[x] = 0;
		ap_uint<AXI_SIZE>* firings = (ap_uint<AXI_SIZE>*)out_stream;
		printf("Persisting all neuron firing HW results...\n");
		for (t = 0; t < RUN_STEPS - 1; t++) {
			for (x = 0, l = 0; l < NUMBER_OF_LAYERS; l++) for (xl = 0; xl < NEURONS_PER_LAYER; xl++, x++) {
				int32_t f_bit = x%AXI_SIZE;
				int32_t f_idx = (x/AXI_SIZE) + AXI_POTENTIAL_OUTPUT_LENGTH;
				if (firings[t * AXI_OUTPUT_LENGTH + f_idx][f_bit]) {
					firing_rate[x] ++;
					if (neuron_type[l][xl] == INHIBITORY_NEURON)
						#if PERSIST_HW_RESULTS == RESULTS_FILE
						fprintf(file1, "%lu,%lu\n", t, x);
						#else
						printf("%lu,%lu\n", t, x);
						#endif
					else
						#if PERSIST_HW_RESULTS == RESULTS_FILE
						fprintf(file1, "%lu,%lu,\n", t, x);
						#else
						printf("%lu,%lu,\n", t, x);
						#endif
				}
			}
		}

		printf("Persisting HW firing rates...\n");
		for (x = 0; x < NUMBER_OF_NEURONS; x++) {
			#if PERSIST_HW_RESULTS == RESULTS_FILE
			fprintf(file2, "%lu,%f\n", x, (((float32_t)firing_rate[x]*1000)/(RUNTIME_MS-2*INPUT_FIRINGS_OFFSET)));
			#else
			printf("%lu,%f\n", x, (((float32_t)firing_rate[x]*1000)/(RUNTIME_MS-2*INPUT_FIRINGS_OFFSET)));
			#endif
		}
	}
	#if PERSIST_HW_RESULTS == RESULTS_FILE
	fclose(file1);
	fclose(file2);

	FILE * file3 = fopen("single_neuron_hw.csv", "w");
	if (file3)
	#endif
	{
		float32_t *v_to_plot = (float32_t*)out_stream;
		printf("Persisting neuron HW potentials...\n");
		for (t = 0; t < RUN_STEPS - 1; t++) {
			int v_idx = (t * AXI_OUTPUT_LENGTH * 2) + 0;
			#if PERSIST_HW_RESULTS == RESULTS_FILE
			fprintf(file3, "%lu,%f\n", t, v_to_plot[v_idx]);
			#else
			printf("%lu,%f\n", t, v_to_plot[v_idx]);
			#endif
		}
	}
	#if PERSIST_HW_RESULTS == RESULTS_FILE
	fclose(file3);
	#endif
}
#endif

#if PERSIST_SW_RESULTS != RESULTS_NONE
void persist_sw_results(uint1_sw_t neuron_type[NUMBER_OF_LAYERS][NEURONS_PER_LAYER], float32_t v[RUN_STEPS * NUMBER_OF_NEURONS]);
void persist_sw_results(uint1_sw_t neuron_type[NUMBER_OF_LAYERS][NEURONS_PER_LAYER], float32_t v[RUN_STEPS * NUMBER_OF_NEURONS]) {

	uint32_t t, x, l, xl;
	#if PERSIST_SW_RESULTS == RESULTS_FILE
	FILE * file1 = fopen("all_neurons_sw.csv", "w");
	FILE * file2 = fopen("firing_rates_sw.csv", "w");
	if (file1 && file2)
	#endif
	{
		int32_t firing_rate[NUMBER_OF_NEURONS];
		for (x = 0; x < NUMBER_OF_NEURONS; x++) firing_rate[x] = 0;
		printf("Persisting all neuron firing SW results...\n");
		for (t = 0; t < RUN_STEPS - 1; t++) {
			for (x = 0, l = 0; l < NUMBER_OF_LAYERS; l++) for (xl = 0; xl < NEURONS_PER_LAYER; xl++, x++) {
				if (v[t * NUMBER_OF_NEURONS + x] >= 35.0f) {
					firing_rate[x] ++;
					if (neuron_type[l][xl] == INHIBITORY_NEURON)
						#if PERSIST_SW_RESULTS == RESULTS_FILE
						fprintf(file1, "%lu,,%lu\n", t, x);
						#else
						printf("%lu,,%lu\n", t, x);
						#endif
					else
						#if PERSIST_SW_RESULTS == RESULTS_FILE
						fprintf(file1, "%lu,%lu,\n", t, x);
						#else
						printf("%lu,%lu,\n", t, x);
						#endif
				}
			}
		}
		printf("Persisting HW firing rates...\n");
		for (x = 0; x < NUMBER_OF_NEURONS; x++) {
			#if PERSIST_SW_RESULTS == RESULTS_FILE
			fprintf(file2, "%lu,%f\n", x, (((float32_t)firing_rate[x]*1000)/(RUNTIME_MS-2*INPUT_FIRINGS_OFFSET)));
			#else
			printf("%lu,%f\n", x, (((float32_t)firing_rate[x]*1000)/(RUNTIME_MS-2*INPUT_FIRINGS_OFFSET)));
			#endif
		}
	}
	#if PERSIST_SW_RESULTS == RESULTS_FILE
	fclose(file1);
	fclose(file2);

	FILE * file3 = fopen("single_neuron_sw.csv", "w");
	if (file3)
	#endif
	{
		printf("Persisting neuron SW potentials...\n");
		for (t = 0; t < RUN_STEPS - 1; t++) {
			uint32_t v_idx = (t * NUMBER_OF_NEURONS) + NEURON_TO_PLOT;
			#if PERSIST_SW_RESULTS == RESULTS_FILE
			fprintf(file3, "%lu,%f\n", t, v[v_idx]);
			#else
			printf("%lu,%f\n", t, v[v_idx]);
			#endif
		}
	}
	#if PERSIST_SW_RESULTS == RESULTS_FILE
	fclose(file3);
	#endif /* PERSIST_SW_RESULTS */
}
#endif

#endif

#endif /* _SNN_RESULTS_H_ */
