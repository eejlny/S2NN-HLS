#ifndef _SNN_NETWORK_PATTERN_H
#define _SNN_NETWORK_PATTERN_H

// Common libraries
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "../snn_config.h"
#include "../common/snn_types.h"
#include "../common/snn_network.h"
#include "snn_network_defs.h"

#if APP_TYPE == APP_PATTERN

// Common interface
uint1_sw_t get_neuron_type(int32_t l, int32_t xl);
uint1_sw_t get_spike(int32_t t, int32_t x);
float32_t get_weight(int32_t l, int32_t xl, int32_t x, int32_t y, uint1_sw_t feedback);
void generate_inputs();
void persist_app_results();

// Specialized methods/variables

static uint32_t trial_number;

// Metrics
static float32_t t_shift_error[NUM_TRAINING_TRIALS];
static float32_t w_error[NUM_TRAINING_TRIALS];
static float32_t trial_success[NUM_TRAINING_TRIALS];
static float32_t correct_trials[NUM_TRAINING_TRIALS];

// Spike trains
static uint1_sw_t p_set_inputs[TRIAL_TIME_MS];
static uint1_sw_t p_set_outputs[TRIAL_TIME_MS];

// Spike timings
static float32_t t_inputs[MAX_TRIAL_SPIKES];
static float32_t t_outputs_expected[MAX_TRIAL_SPIKES];

// Spike trials
static float32_t t_spiked[NUMBER_OF_NEURONS][MAX_TRIAL_SPIKES];

void feedback_error(int32_t t);

//static w_dat_sw_t	weights_delta[NUMBER_OF_NEURONS][NEURONS_PER_LAYER];

//static w_dat_sw_t	weights_delta[NUMBER_OF_NEURONS][][NEURONS_PER_LAYER];
//static w_dat_sw_t	propagated_error[NUMBER_OF_NEURONS][NEURONS_PER_LAYER];

static w_dat_sw_t	weights_delta[NUMBER_OF_NEURONS][NEURONS_PER_LAYER];

// Methods

uint1_sw_t get_neuron_type(int32_t l, int32_t xl) {
	//if (l < OUTPUT_LAYER) return get_random() < INHIBITORY_NEURON_PERC;
	/*else*/ return EXCITATORY_NEURON;
}

uint1_sw_t get_spike(int32_t t, int32_t x) {
	if (x == 0) return p_set_inputs[t % TRIAL_TIME_MS];
	//else return 0;
	return 0;
}

float32_t exp_window(float32_t a, float32_t b){
	if (a == INFINITY && b == INFINITY) { return ALPHA_POST; }
	else if (a < b) return ALPHA_POST * exp((a - b)/TAU_PARAM);
	else return -ALPHA_PRE * exp((b - a)/TAU_PARAM);
}

float32_t get_weight(int32_t l, int32_t xl, int32_t x, int32_t y, uint1_sw_t feedback) {
	if (feedback == 0) { // Initial phase
		if (l == 0 && y == 0) { // Input-Hidden layer
			/*if (y == 0)*/ return INPUT_SYNAPSE_WEIGHT; //+ (SYNAPSE_WEIGHT - 1/200); // Reference
			//else if (y == 1 && x < 3) return INPUT_SYNAPSE_WEIGHT; // Reference
			//else if (y == 2 && x >= 3) return INPUT_SYNAPSE_WEIGHT; // Reference
		} else if (l == OUTPUT_LAYER && xl == 0) { // Hidden-Output layer
			return SYNAPSE_WEIGHT; //SYNAPSE_WEIGHT;
		}
	} else { // Feedback phase
		float32_t delta = weights_delta[x][y];
		return synapse_weights[x][y] + (LEARNING_RATE * delta);
	}
	return 0;
}

void generate_inputs() {
	uint32_t input_spikes = 0, output_spikes = 0;
	float32_t prob_spike = ((float32_t)MAX_TRIAL_SPIKES/TRIAL_TIME_MS)*1.3;
	for (int32_t k = 0; k < TRIAL_TIME_MS; k++) {
		// Input pattern
		if (get_random() < prob_spike && input_spikes < MAX_TRIAL_SPIKES) {
			p_set_inputs[k] = 1;
			t_inputs[input_spikes++] = k;
		}
		// Output pattern
		if (k > 50 && get_random() < prob_spike && output_spikes < MAX_TRIAL_SPIKES) {
			p_set_outputs[k] = 1;
			t_outputs_expected[output_spikes++] = k;
		}
	}
}

void refresh_delta_weights() {
	int32_t x, l, xl, y, o;
	for (l = OUTPUT_LAYER; l >=0; l--) {
		for (xl = 0; xl < NEURONS_PER_LAYER; xl++) {
			x = (l * NEURONS_PER_LAYER) + xl;
			if (l == OUTPUT_LAYER && xl != 0) break;

			int32_t previous_layer_idx = ((l - 1) * NEURONS_PER_LAYER);

			float32_t *t_actual = t_spiked[x];

			// Iterate all pre-synaptic connections
			for (y = 0; y < NEURONS_PER_LAYER; y++) {

				float32_t *t_pre_spikes = t_spiked[previous_layer_idx + y];

				// Process only non-null synapses
				if (l == OUTPUT_LAYER && xl == 0) { // Output-Hidden

					//float32_t t1 = exp_window(fr_pre_value, t_output_expected[trial_number]);
					//float32_t t2 = exp_window(fr_pre_value, t_actual);
					float sum = 0;
					for (uint32_t s = 0; s < MAX_TRIAL_SPIKES; s++) {
						float32_t t1 = exp_window(t_pre_spikes[s], t_outputs_expected[s]);
						float32_t t2 = exp_window(t_pre_spikes[s], t_actual[s]);
						sum += (t1 - t2);
					}
					weights_delta[x][y] = sum;
					if(trial_number == 400) {
						printf("a");
					}

				} else if (l == HIDDEN_LAYER && y == 0) { // Hidden-Hidden-Input

					// Set total of postsynaptic neurons
					//int32_t total_post = NEURONS_PER_LAYER;
					//int32_t total_pre = NEURONS_PER_LAYER;
					//if (l == OUTPUT_LAYER - 1) total_post = 1;
					//if (l == 0) total_pre = 1;

					// Set input value
					//if (l == 0) fr_pre_value = t_input_trials[y][trial_number];

					// Collect propagated error
					//float32_t sum = 0;
					//for (o = 0; o < total_post; o++) {
					//float32_t t1 = exp_window(t_input_trials[y][trial_number], t_output_trials[xl][trial_number]);
					//float32_t t2 = exp_window(t_input_trials[y][trial_number], t_actual);
					//sum = (t1 - t2) * synapse_weights[post_layer_idx + o][xl];
					//}
					float32_t sum = 0;
					for (uint32_t s = 0; s < MAX_TRIAL_SPIKES; s++) {
						float32_t t1 = exp_window(t_inputs[s], t_outputs_expected[s]);
						float32_t t2 = exp_window(t_inputs[s], t_actual[s]);
						sum += (t1 - t2);
					}
					weights_delta[x][y] = sum * synapse_weights[OUTPUT_NEURON][xl];///((float32_t)total_pre);
				}
			}
		}
	}
}

void feedback_error(int32_t t) {

	if ((t % TRIAL_TIME_MS) == (TRIAL_TIME_MS - 1)) {
		int32_t t_start = t + 1 - TRIAL_TIME_MS;

		for (uint32_t n = 0; n < NUMBER_OF_NEURONS; n++) {

			uint32_t spike_index = 0;
			for (uint32_t k = 0; k < MAX_TRIAL_SPIKES; k++)
				t_spiked[n][k] = INFINITY;

			for (uint32_t i = 0; i < TRIAL_TIME_MS; i++) {
				if (v_sw[((t_start + i) * NUMBER_OF_NEURONS) + n] >= 35.0f) {
					t_spiked[n][spike_index++] = (float32_t)i;
				}
				if (spike_index >= MAX_TRIAL_SPIKES) break;
			}
		}

		// Refresh delta weights
		refresh_delta_weights();

		// Initialize global errors
		//int32_t sum_decoded = 0;
		//int32_t correct = 0;
		/*int32_t error = (int32_t)(t_spiked[OUTPUT_NEURONS + n] - t_output_trials[n][trial_number]);
		if (error < -20 || error > 20) error = 20;

		if(abs(error) <= PASSING_THRESHOLD) {
			correct ++; output_correct[n] ++; correct_trials[n][trial_number] = 1;
		} else correct_trials[n][trial_number] = 0;

		if (abs(t_spiked[OUTPUT_NEURONS + n] - DELAY_OUTPUT_HIGH_MS) <= PASSING_THRESHOLD) sum_decoded += v;
		trial_success[n][trial_number] = (float32_t)output_correct[n]/(float32_t)(trial_number + 1);
		global_correct += output_correct[n];

		// shift error
		t_shift_error_accum[n] += abs(error);
		t_shift_error_accum[NUM_OUTPUTS] += abs(error);
		t_shift_error[n][trial_number] += t_shift_error_accum[n]/(float32_t)(trial_number);*/
		t_shift_error[trial_number] = 0;
		for (int32_t s = 0; s < MAX_TRIAL_SPIKES; s++) {
			int32_t diff = t_spiked[OUTPUT_NEURON][s] - t_outputs_expected[s];
			if (diff > 100 || diff < -100) diff = 100;
			if (diff < 0) diff *= -1;
			t_shift_error[trial_number] += diff;
		}

		// weight delta error
		w_error[trial_number] = 0;
		for (int32_t s = 0; s < NEURONS_PER_LAYER; s++) {
			float32_t delta_w = weights_delta[OUTPUT_NEURON][s];
			if (delta_w < 0) delta_w *= -1;
			w_error[trial_number] += delta_w;
		}
		//w_error[trial_number] /= 2;
		//w_error[NUM_OUTPUTS][trial_number] += w_error[n][trial_number];*/

		printf("Weight delta: %f, Spkie-Shift: %f\n", w_error[trial_number], t_shift_error[trial_number]);

		// Update weights
		init_network(0, 1);
		trial_number ++;
	}
}

void persist_trials() {
	#if PERSIST_SW_RESULTS == RESULTS_FILE
	FILE * file1 = fopen("neuron_trials.csv", "w");
	if (file1)
	#endif /* PERSIST_SW_RESULTS */
	{
		for (int32_t t = 1; t < NUM_TRAINING_TRIALS - 1; t++) {
			#if PERSIST_SW_RESULTS == RESULTS_FILE
			fprintf(file1, "%d,%f,%f,%f,%f", t, trial_success[t], t_shift_error[t], w_error[t], correct_trials[t]);
			#endif
			/*for (int32_t s = 0; s < NEURONS_PER_LAYER; s++) {
				#if PERSIST_SW_RESULTS == RESULTS_FILE
				fprintf(file1, ",%f", weights_delta[OUTPUT_NEURONS + i][s]);
				#endif
			}*/
			#if PERSIST_SW_RESULTS== RESULTS_FILE
			fprintf(file1, "\n");
			#endif
		}
		printf("Global output accuracy: %.3f\n", trial_success[NUM_TRAINING_TRIALS-1]);
	}
	#if PERSIST_SW_RESULTS == RESULTS_FILE
	fclose(file1);
	#endif
}

void persist_firings() {
	int32_t t, l, x, xl;
	#if PERSIST_SW_RESULTS == RESULTS_FILE
	FILE * file1 = fopen("all_neurons_sw.csv", "w");
	if (file1)
	#endif
	{
		printf("Persisting all neuron firing...\n");
		for (t = 0; t < RUN_STEPS - 1; t++) {
			if (p_set_inputs[t%TRIAL_TIME_MS]) {
				#if PERSIST_SW_RESULTS == RESULTS_FILE
				fprintf(file1, "%lu,%ld\n", t, 1);
				#else
				printf("%lu,%ld\n", t, 1);
				#endif
			}

			if (v_sw[(t * NUMBER_OF_NEURONS) + OUTPUT_NEURON] >= 35.0f) {
				#if PERSIST_SW_RESULTS == RESULTS_FILE
				fprintf(file1, "%lu,%ld,\n", t, 2);
				#else
				printf("%lu,%ld,\n", t, 2);
				#endif
			}
		}
	}
	#if PERSIST_SW_RESULTS == RESULTS_FILE
	fclose(file1);
	#endif
}

void persist_outputs() {
	printf("Persisting neuron outputs...\n");
	#if PERSIST_SW_RESULTS == RESULTS_FILE
	FILE * file1 = fopen("neuron_raw.csv", "w");
	if (file1)
	#endif /* PERSIST_SW_RESULTS */
	{
		for (int32_t t = 0; t < RUN_STEPS - 1; t++) {
			#if PERSIST_SW_RESULTS == RESULTS_FILE
			fprintf(file1, "%lu,%f\n", t, v_sw[(t * NUMBER_OF_NEURONS) + OUTPUT_NEURON]);
			#else
			printf("%lu,%f\n", t, v_sw[(t * NUMBER_OF_NEURONS) + OUTPUT_NEURON + i]);
			#endif
		}
	}
	#if PERSIST_SW_RESULTS == RESULTS_FILE
	fclose(file1);
	#endif
}

void persist_app_results() {
	persist_trials();
	persist_firings();
	persist_outputs();
}

#endif /* APP_TYPE */

#endif /* _SNN_NETWORK_PATTERN_H */
