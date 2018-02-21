#ifndef _SNN_NETWORK_XOR_H
#define _SNN_NETWORK_XOR_H

// Common libraries
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "../snn_config.h"
#include "../common/snn_types.h"
#include "../common/snn_network.h"
#include "snn_network_defs.h"

#if APP_TYPE == APP_XOR

// Common interface
uint1_sw_t get_neuron_type(int32_t l, int32_t xl);
uint1_sw_t get_spike(int32_t t, int32_t x);
float32_t get_weight(int32_t l, int32_t xl, int32_t x, int32_t y, uint1_sw_t feedback);
void generate_inputs();
void persist_app_results();

// Specialized methods/variables

static uint32_t trial_number;
static float32_t t_shift_error_accum;
static float32_t t_shift_error[NUM_TRAINING_TRIALS];
static float32_t w_error[2*NEURONS_PER_LAYER][NUM_TRAINING_TRIALS];
static float32_t trial_success[NUM_TRAINING_TRIALS];
static float32_t learning_success[NUM_TRAINING_TRIALS];
static float32_t t_spikes_trials[NUM_TRAINING_TRIALS];

// Inputs/Outputs
static float32_t t_input_trials[NUM_INPUTS][NUM_TRAINING_TRIALS];
static float32_t t_output_trials[NUM_TRAINING_TRIALS];

static float32_t t_spiked[NUMBER_OF_NEURONS];
static uint32_t total_correct;
static uint32_t valid_trial;

static uint1_sw_t p_set_inputs[NUM_INPUTS][RUN_STEPS];
void feedback_error(int32_t t);

// Methods

uint1_sw_t get_neuron_type(int32_t l, int32_t xl) {
	if (l < OUTPUT_LAYER) return get_random() < INHIBITORY_NEURON_PERC;
	else return EXCITATORY_NEURON;
}

uint1_sw_t get_spike(int32_t t, int32_t x) {
	if (x < NUM_INPUTS) return p_set_inputs[x][t];
	else return 0;
}

float32_t exp_window(float32_t t_pre, float32_t t_post){
	float32_t delta_t = t_pre - t_post;
	if (t_pre == INFINITY && t_post == INFINITY) {
		return ALPHA_PLUS;
	} else if (delta_t < 0) {
		return ALPHA_PLUS * exp(delta_t/TAU_PLUS);
	} else {
		return ALPHA_MINUS * exp((delta_t * -1.0)/TAU_MINUS);
	}
}

float32_t get_new_weight(float32_t current_weight, float32_t delta_weight) {
	if (delta_weight >= 0)
		return current_weight + LEARNING_RATE(learning_success[trial_number]) * delta_weight * (W_MAX - current_weight);
	else
		return current_weight + LEARNING_RATE(learning_success[trial_number]) * delta_weight * (current_weight - W_MIN);
}

float32_t get_weight(int32_t l, int32_t xl, int32_t x, int32_t y, uint1_sw_t feedback) {
	if (feedback == 0) { // Initial phase
		if (l == 0 && y < NUM_INPUTS) { // Input-Hidden layer
			return 0.06 + (get_random() / 50);
		} else if (l > 0 && l < OUTPUT_LAYER) { // Hidden-Output layer
			return (get_random() / 10); //- 0.05;
		} else if (l == OUTPUT_LAYER && xl < NUM_OUTPUTS) { // Hidden-Output layer
			return 0.10 + (get_random() / 10); //- 0.05;
		}
	} else { // Feedback phase
		//float32_t delta = weights_delta[x][y];
		//if (delta > 3) delta = 3;
		//if (delta < -3) delta = -3;
		return synapse_weights[x][y];// - (LEARNING_RATE * delta);
	}
	return 0;
}

void refresh_delta_weights() {
	int32_t x, l, xl, y;
	for (l = HIDDEN_LAYERS; l >=0; l--) {
		for (xl = 0; xl < NEURONS_PER_LAYER; xl++) {
			x = (l * NEURONS_PER_LAYER) + xl;
			if (l == OUTPUT_LAYER && xl == NUM_OUTPUTS) break;

			int32_t post_layer_idx = ((l + 1) * NEURONS_PER_LAYER);
			int32_t previous_layer_idx = ((l - 1) * NEURONS_PER_LAYER);
			int32_t output_layer_idx = OUTPUT_NEURON;

			bool sum = 0;
			for (int k = 0; k < NEURONS_PER_LAYER; k++) {
				if (synapse_weights[x][y] < 0)
					sum += (synapse_weights[x][y]*-1);
				else
					sum += (synapse_weights[x][y]);
			}

			// Iterate all pre-synaptic connections
			for (y = 0; y < NEURONS_PER_LAYER; y++) {

				// Process only non-null synapses
				if (l == OUTPUT_LAYER && xl < NUM_INPUTS) { // Output-Hidden

					float32_t t1 = exp_window(t_spiked[previous_layer_idx + y], t_output_trials[trial_number]);
					float32_t t2 = exp_window(t_spiked[previous_layer_idx + y], t_spiked[x]);
					synapse_weights[x][y] = get_new_weight(synapse_weights[x][y], t1 - t2);///((float32_t)NEURONS_PER_LAYER);

					//w_error[y][trial_number] = t1 - t2;
					w_error[y][trial_number] = synapse_weights[x][y];

				} else if (l == 0 && y < NUM_INPUTS) { // Hidden-Input

					float32_t time = exp_window(t_input_trials[y][trial_number], t_spiked[x]);
					float32_t t1 = exp_window(t_input_trials[y][trial_number], t_output_trials[trial_number]);
					float32_t t2 = exp_window(t_input_trials[y][trial_number], t_spiked[OUTPUT_NEURON]);

					float32_t factor = synapse_weights[x][y];
					if (factor < 0) factor = factor * -1;
					factor = factor / sum;

					synapse_weights[x][y] = get_new_weight(synapse_weights[x][y], t1 - t2);

					//w_error[x+NEURONS_PER_LAYER][trial_number] = t1 - t2;
					w_error[x+NEURONS_PER_LAYER][trial_number] = synapse_weights[x][y];
				}
			}
		}
	}
}

void generate_inputs() {
	uint32_t pattern = 0;
	uint32_t t = 0;
	for (int32_t k = 0; k < NUM_TRAINING_TRIALS; k++) {

		// Set reference and inputs
		//t_input_trials[0][k] = DELAY_REFERENCE;
		float32_t operand_1 = get_random() < 0.5; t_input_trials[0][k] = operand_1 == 0? DELAY_INPUT_LOW_MS : DELAY_INPUT_HIGH_MS;
		float32_t operand_2 = get_random() < 0.5; t_input_trials[1][k] = operand_2 == 0? DELAY_INPUT_LOW_MS : DELAY_INPUT_HIGH_MS;

		//float32_t operand_2 = (pattern == 1) ? operand_1 : (operand_1 == 0? 1 : 0);
		//t_input_trials[1][k] = operand_2 == 0? DELAY_INPUT_LOW_MS : DELAY_INPUT_HIGH_MS;

		// Set target output
		t_output_trials[k] =  (operand_1 == operand_2? DELAY_OUTPUT_LOW_MS: DELAY_OUTPUT_HIGH_MS);

		//t_output_trials[k] = DELAY_OUTPUT_HIGH_MS;//TARGET_FIRINGS_TRIAL;
		//random_value > 0.5 ? DELAY_OUTPUT_HIGH_MS : DELAY_OUTPUT_LOW_MS;

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
				#if RUN_TYPE == TYPE_HLS
				int32_t f_bit = n%AXI_SIZE;
				int32_t f_idx = (n/AXI_SIZE) + AXI_POTENTIAL_OUTPUT_LENGTH;
				ap_uint<AXI_SIZE>* firings = (ap_uint<AXI_SIZE>*)out_hw;
				if (firings[(t_start + i) * AXI_OUTPUT_LENGTH + f_idx][f_bit]) {
				#else
				if (v_sw[((t_start + i) * NUMBER_OF_NEURONS) + n] >= 35.0f) {
				#endif
					t_spiked[n] = i;
					//t_spiked[n] ++;
					break;
				}
			}
			//t_spiked[n] = t_spiked[n] * (1000/TRIAL_TIME_MS);
		}

		// Initialize global errors
		t_shift_error[trial_number] = 0;
		int32_t error = (int32_t)(t_spiked[OUTPUT_NEURON] - t_output_trials[trial_number]);

		//if ((error) <= THRESHOLD_FREQ) correct_epoch = 1;
		if (abs(error) <= THRESHOLD_FREQ) {
			total_correct ++; trial_success[trial_number] = 1;
		} else {
			trial_success[trial_number] = 0;
		}

		t_spikes_trials[trial_number] = t_spiked[OUTPUT_NEURON];

		int32_t total_trials = 0;
		int32_t correct_trials = 0;
		for (uint32_t k = 0; k < 1000; k++) {
			if (trial_number > k) {
				total_trials ++;
				if (trial_success[trial_number - k] > 0) correct_trials ++;
			}
		}

		learning_success[trial_number] = (float32_t)correct_trials/(float32_t)(total_trials+1);

		// shift error
		//t_shift_error_accum += abs(error);
		if (error > TRIAL_TIME_MS/2 || error < -TRIAL_TIME_MS/2)
			t_shift_error[trial_number] = TRIAL_TIME_MS/2;
		else
			//t_shift_error[trial_number] = (error); //t_shift_error_accum/(float32_t)(trial_number);
			t_shift_error[trial_number] = (error*error)/2;


		// Refresh delta weights
		refresh_delta_weights();

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
			fprintf(file1, "%d,%f,%f,%f,%f,%f,%f,%f", t, learning_success[t], t_shift_error[t], w_error[0][t], w_error[1][t], w_error[OUTPUT_NEURON][t], w_error[OUTPUT_NEURON+1][t], w_error[4][t]);
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
		printf("Global learning accuracy: %.3f\n", learning_success[NUM_TRAINING_TRIALS-2]);
	}
	#if PERSIST_SW_RESULTS == RESULTS_FILE
	fclose(file1);
	#endif
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
	#if PERSIST_SW_RESULTS == RESULTS_FILE
	FILE * file1 = fopen("neuron_raw.csv", "w");
	if (file1)
	#endif /* PERSIST_SW_RESULTS */
	{
		for (int32_t t = 0; t < RUN_STEPS - 1; t++) {
			#if PERSIST_SW_RESULTS == RESULTS_FILE
			fprintf(file1, "%lu,%f\n", t, v_sw[(t * NUMBER_OF_NEURONS) + OUTPUT_NEURON]);
			#else
			printf("%lu,%f\n", t, v_sw[(t * NUMBER_OF_NEURONS) + OUTPUT_NEURONS + i]);
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

#endif /* _SNN_NETWORK_XOR_H */
