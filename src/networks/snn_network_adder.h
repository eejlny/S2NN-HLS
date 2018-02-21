#ifndef _SNN_NETWORK_ADDER_H
#define _SNN_NETWORK_ADDER_H

// Common libraries
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "../snn_config.h"
#include "../common/snn_types.h"
#include "../common/snn_network.h"
#include "snn_network_defs.h"

#if APP_TYPE == APP_ADDER

// Common interface
uint1_sw_t get_neuron_type(int32_t l, int32_t xl);
uint1_sw_t get_spike(int32_t t, int32_t x);
float32_t get_weight(int32_t l, int32_t xl, int32_t x, int32_t y, uint1_sw_t feedback);
void generate_inputs();
void persist_app_results();

// Specialized methods/variables

static uint32_t trial_number;
static float32_t t_shift_error_accum[NUM_OUTPUTS+1];
static float32_t t_shift_error[NUM_OUTPUTS+1][NUM_TRAINING_TRIALS];
static float32_t w_error[NUM_OUTPUTS+1][NUM_TRAINING_TRIALS];
static float32_t trial_success[NUM_OUTPUTS+1][NUM_TRAINING_TRIALS];
static float32_t input_values[2][NUM_TRAINING_TRIALS];
static float32_t correct_trials[NUM_OUTPUTS+1][NUM_TRAINING_TRIALS];

// Inputs/Outputs
static float32_t t_input_trials[NUM_INPUTS][NUM_TRAINING_TRIALS];
static float32_t t_output_trials[NUM_OUTPUTS][NUM_TRAINING_TRIALS];


static float32_t t_spiked[NUMBER_OF_NEURONS];
static uint32_t output_correct[NUM_OUTPUTS];

static uint1_sw_t p_set_inputs[NUM_INPUTS][RUN_STEPS];
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
	if (x < NUM_INPUTS) return p_set_inputs[x][t];
	else return 0;
}

float32_t exp_window(float32_t a, float32_t b){
	if (a == INFINITY && b == INFINITY) { return ALPHA_POST; }
	else if (a < b) return ALPHA_POST * exp((a - b)/TAU_PARAM);
	else return -ALPHA_PRE * exp((b - a)/TAU_PARAM);
}

float32_t get_weight(int32_t l, int32_t xl, int32_t x, int32_t y, uint1_sw_t feedback) {
	if (feedback == 0) { // Initial phase
		if (l == 0 && y < NUM_INPUTS) { // Input-Hidden layer
			/*if (y == 0)*/ return INPUT_SYNAPSE_WEIGHT; //+ (SYNAPSE_WEIGHT - 1/200); // Reference
			//else if (y == 1 && x < 3) return INPUT_SYNAPSE_WEIGHT; // Reference
			//else if (y == 2 && x >= 3) return INPUT_SYNAPSE_WEIGHT; // Reference
		} else if (l == OUTPUT_LAYER && xl < NUM_OUTPUTS) { // Hidden-Output layer
			return SYNAPSE_WEIGHT; //SYNAPSE_WEIGHT;
		}/* else if (l > 0 && l < OUTPUT_LAYER) { // Hidden-Output layer
			return SYNAPSE_WEIGHT;
		}*/
	} else { // Feedback phase
		float32_t delta = weights_delta[x][y];
		return synapse_weights[x][y] + (LEARNING_RATE * delta);
	}
	return 0;
}

void refresh_delta_weights() {
	int32_t x, l, xl, y, o;
	for (l = HIDDEN_LAYERS; l >=0; l--) {
		for (xl = 0; xl < NEURONS_PER_LAYER; xl++) {
			x = (l * NEURONS_PER_LAYER) + xl;
			if (l == OUTPUT_LAYER && xl >= NUM_OUTPUTS) break;

			int32_t post_layer_idx = ((l + 1) * NEURONS_PER_LAYER);
			int32_t previous_layer_idx = ((l - 1) * NEURONS_PER_LAYER);

			float32_t t_actual = t_spiked[x];

			// Iterate all pre-synaptic connections
			for (y = 0; y < NEURONS_PER_LAYER; y++) {

				float32_t fr_pre_value = t_spiked[previous_layer_idx + y];

				// Process only non-null synapses
				if (l == OUTPUT_LAYER && xl < NUM_OUTPUTS) { // Output-Hidden

					float32_t t1 = exp_window(fr_pre_value, t_output_trials[xl][trial_number]);
					float32_t t2 = exp_window(fr_pre_value, t_actual);
					weights_delta[x][y] = (t1 - t2)/((float32_t)NEURONS_PER_LAYER);

				} else if (l < OUTPUT_LAYER) { // Hidden-Hidden-Input

					//uint1_sw_t do_delta = /*(l == 0 && y < NUM_INPUTS) ||*/ (y == 0) || (y == 1 && xl < 3) || (y == 2 && xl >= 3);
					if (y < NUM_INPUTS) {
						//if (l == 0 && y >= NUM_INPUTS) break;
						//if (y == 1 && xl >= 3) break;
						//if (y == 2 && xl < 3 && xl > 0) break;

						// Set total of postsynaptic neurons
						int32_t total_post = NEURONS_PER_LAYER;
						int32_t total_pre = NEURONS_PER_LAYER;
						if (l == OUTPUT_LAYER - 1) total_post = NUM_OUTPUTS;
						if (l == 0) total_pre = NUM_INPUTS;

						// Set input value
						if (l == 0) fr_pre_value = t_input_trials[y][trial_number];

						// Collect propagated error
						float32_t sum = 0;
						for (o = 0; o < total_post; o++) {
							float32_t t1 = exp_window(fr_pre_value, t_output_trials[xl][trial_number]);
							float32_t t2 = exp_window(fr_pre_value, t_actual);
							sum = (t1 - t2) * synapse_weights[post_layer_idx + o][xl];
						}
						weights_delta[x][y] = sum/((float32_t)total_pre * (float32_t)NUM_INPUTS);
					}
				}
			}
		}
	}
}

void generate_inputs() {
	uint32_t t = 0;
	for (int32_t k = 0; k < NUM_TRAINING_TRIALS; k++) {

		// Set reference and inputs
		//t_input[0] = DELAY_REFERENCE;
		t_input_trials[0][k] = DELAY_REFERENCE;

		uint32_t op1 = get_random() * (2 - 0.00001); input_values[0][k] = op1;
		uint32_t op2 = get_random() * (pow(2, ADDER_BITS) - 0.00001); input_values[1][k] = op2;
		for (int32_t x = 0, v = 1; x < ADDER_BITS; x++, v<<=1) {
			t_input_trials[x + 1][k] = ((op1 & v) > 0)? DELAY_INPUT_HIGH_MS : DELAY_INPUT_LOW_MS;
			t_input_trials[x + ADDER_BITS + 1][k] = ((op2 & v) > 0)? DELAY_INPUT_HIGH_MS : DELAY_INPUT_LOW_MS;
		}

		// Set target output
		uint32_t op3 = op1 + op2;
		for (int32_t x = 0, v = 1; x < NUM_OUTPUTS; x++, v<<=1)
			t_output_trials[x][k] = (((op3 & v) > 0)? DELAY_OUTPUT_HIGH_MS : DELAY_OUTPUT_LOW_MS);

		// Store timing inputs
		for (int32_t subt = 0; subt < TRIAL_TIME_MS; subt++, t++)
			for (int32_t x = 0; x < NUM_INPUTS; x++) p_set_inputs[x][t] = (t_input_trials[x][k] == subt);
	}
}

void feedback_error(int32_t t) {

	if ((t % TRIAL_TIME_MS) == (TRIAL_TIME_MS - 1)) {
		int32_t t_start = t + 1 - TRIAL_TIME_MS;

		for (int32_t n = 0; n < NUMBER_OF_NEURONS; n++) {
			t_spiked[n] = INFINITY;
			for (int32_t i = 0; i < TRIAL_TIME_MS; i++) {
				if (v_sw[((t_start + i) * NUMBER_OF_NEURONS) + n] >= 35.0f) {
					t_spiked[n] = i;
					//t_spiked[n] ++;
					break;
				}
			}
		}

		// Refresh delta weights
		refresh_delta_weights();

		// Initialize global errors
		int32_t global_correct = 0;
		t_shift_error[NUM_OUTPUTS][trial_number] = 0;
		w_error[NUM_OUTPUTS][trial_number] = 0;

		int32_t sum_decoded = 0;
		int32_t correct = 0;
		for (int32_t n = 0, v = 1; n < NUM_OUTPUTS; n++, v<<=1) {
			int32_t error = (int32_t)(t_spiked[OUTPUT_NEURONS + n] - t_output_trials[n][trial_number]);
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
			t_shift_error[n][trial_number] += t_shift_error_accum[n]/(float32_t)(trial_number);

			// weight delta error
			w_error[n][trial_number] = 0;
			for (int32_t s = 0; s < NEURONS_PER_LAYER; s++) {
				float32_t delta_w = weights_delta[OUTPUT_NEURONS + n][s];
				w_error[n][trial_number] += delta_w;
			}
			w_error[n][trial_number] /= 2;
			w_error[NUM_OUTPUTS][trial_number] += w_error[n][trial_number];
		}
		t_shift_error[NUM_OUTPUTS][trial_number] = t_shift_error_accum[NUM_OUTPUTS]/(float32_t)(trial_number * NUM_OUTPUTS);
		w_error[NUM_OUTPUTS][trial_number] /= NUM_OUTPUTS;
		trial_success[NUM_OUTPUTS][trial_number] = (float32_t)global_correct/(float32_t)(trial_number * NUM_OUTPUTS);
		correct_trials[NUM_OUTPUTS][trial_number] = correct;

		int32_t input1 = input_values[0][trial_number];
		int32_t input2 = input_values[1][trial_number];
		int32_t expected = (input1 + input2) % (int32_t)(pow(2, NUM_OUTPUTS));
		printf("Trial %2d (%d/%d)| Input 1: %d, Input 2: %d, Exp/Curr: %d/%d\n",
				trial_number, correct, NUM_OUTPUTS, input1, input2, expected, sum_decoded);
		if (correct == NUM_OUTPUTS) {
			//if (expected != sum_decoded) {
			//	printf("Fatal issue. Mismatch between decoded and expected value"); exit(-1);
			//}
		}

		// Update weights
		init_network(0, 1);
		trial_number ++;
	}
}

void persist_trials() {
	for (int32_t i = 0; i < NUM_OUTPUTS + 1; i++) {
		#if PERSIST_SW_RESULTS == RESULTS_FILE
		char name[18];
		sprintf(name, "neuron_%d_trials.csv", i);
		FILE * file1 = fopen(name, "w");
		if (file1)
		#endif /* PERSIST_SW_RESULTS */
		{
			for (int32_t t = 1; t < NUM_TRAINING_TRIALS - 1; t++) {
				#if PERSIST_SW_RESULTS == RESULTS_FILE
				fprintf(file1, "%d,%f,%f,%f,%f", t, trial_success[i][t], t_shift_error[i][t], w_error[i][t], correct_trials[i][t]);
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
			if(i == NUM_OUTPUTS)
				printf("Global output accuracy: %.3f\n", trial_success[i][NUM_TRAINING_TRIALS-2]);
			else
				printf("Output neuron %d accuracy: %.3f\n", i, trial_success[i][NUM_TRAINING_TRIALS-2]);
		}
		#if PERSIST_SW_RESULTS == RESULTS_FILE
		fclose(file1);
		#endif
	}
}

void persist_firings() {
	uint32_t t, l, x, xl;
	#if PERSIST_SW_RESULTS == RESULTS_FILE
	FILE * file1 = fopen("all_neurons_sw.csv", "w");
	if (file1)
	#endif
	{
		printf("Persisting all neuron firing...\n");
		for (t = 0; t < RUN_STEPS - 1; t++) {
			for (x = 0; x < NUM_INPUTS; x++) {
				if (p_set_inputs[x][t]) {
					#if PERSIST_SW_RESULTS == RESULTS_FILE
					fprintf(file1, "%lu,%ld\n", t, x-NUM_INPUTS);
					#else
					printf("%lu,%ld\n", t, x-NUM_INPUTS);
					#endif
				}
			}

			for (x = 0, l = 0; l < NUMBER_OF_LAYERS; l++) for (xl = 0; xl < NEURONS_PER_LAYER; xl++, x++) {
				if (v_sw[t * NUMBER_OF_NEURONS + x] >= 35.0f) {
					if (neuron_type[l][xl] == INHIBITORY_NEURON)
						#if PERSIST_SW_RESULTS == RESULTS_FILE
						fprintf(file1, "%lu,%ld\n", t, x);
						#else
						printf("%lu,%ld\n", t, x);
						#endif
					else
						#if PERSIST_SW_RESULTS == RESULTS_FILE
						fprintf(file1, "%lu,%ld,\n", t, x);
						#else
						printf("%lu,%ld,\n", t, x);
						#endif
				}
			}
		}
	}
	#if PERSIST_SW_RESULTS == RESULTS_FILE
	fclose(file1);
	#endif
}

void persist_outputs() {
	printf("Persisting neuron outputs...\n");
	for (int32_t i = 0; i < NUM_OUTPUTS; i++) {
		#if PERSIST_SW_RESULTS == RESULTS_FILE
		char name[18];
		sprintf(name, "neuron_%d.csv", i);
		FILE * file1 = fopen(name, "w");
		if (file1)
		#endif /* PERSIST_SW_RESULTS */
		{
			for (int32_t t = 0; t < RUN_STEPS - 1; t++) {
				#if PERSIST_SW_RESULTS == RESULTS_FILE
				fprintf(file1, "%lu,%f\n", t, v_sw[(t * NUMBER_OF_NEURONS) + OUTPUT_NEURONS + i]);
				#else
				printf("%lu,%f\n", t, v_sw[(t * NUMBER_OF_NEURONS) + OUTPUT_NEURONS + i]);
				#endif
			}
		}
		#if PERSIST_SW_RESULTS == RESULTS_FILE
		fclose(file1);
		#endif
	}
}

void persist_app_results() {
	persist_trials();
	persist_firings();
	persist_outputs();
}

#endif /* APP_TYPE */

#endif /* _SNN_NETWORK_ADDER_H */
