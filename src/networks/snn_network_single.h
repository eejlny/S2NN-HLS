#ifndef _SNN_NETWORK_SINGLE_H
#define _SNN_NETWORK_SINGLE_H

// Common libraries
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "../snn_config.h"
#include "../common/snn_types.h"
#include "../common/snn_network.h"
#include "snn_network_defs.h"

#if APP_TYPE == APP_SINGLE

// Common interface
uint1_sw_t get_neuron_type(int32_t l, int32_t xl);
uint1_sw_t get_spike(int32_t t, int32_t x);
float32_t get_weight(int32_t l, int32_t xl, int32_t x, int32_t y, uint1_sw_t feedback);
void generate_inputs();
void persist_app_results();

// Specialized methods/variables

static uint32_t trial_number;
static float32_t t_shift_error[NUM_TRAINING_TRIALS];
static float32_t w_error[2*NEURONS_PER_LAYER][NUM_TRAINING_TRIALS];
static float32_t trial_success[NUM_TRAINING_TRIALS];
static float32_t firing_rates[NUM_TRAINING_TRIALS];

// Inputs/Outputs
static float32_t t_input_trials[NUM_TRAINING_TRIALS];
static float32_t t_output_trials[NUM_TRAINING_TRIALS];

static float32_t spiking_fr[NUMBER_OF_NEURONS];
static uint32_t output_correct;
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

float32_t exp_window(float32_t a, float32_t b){
	if (a == INFINITY && b == INFINITY) {
		return ALPHA_PLUS;
	} else if (a < b) {
		return ALPHA_PLUS * exp((a - b)/TAU_PLUS);
	} else {
		return ALPHA_MINUS * exp((b - a)/TAU_MINUS);
	}
}

float32_t get_new_weight(float32_t current_weight, float32_t delta_weight) {
	if (delta_weight >= 0)
		return current_weight + LEARNING_RATE * delta_weight * (W_MAX - current_weight);
	else
		return current_weight + LEARNING_RATE * delta_weight * (current_weight - W_MIN);
}

float32_t get_weight(int32_t l, int32_t xl, int32_t x, int32_t y, uint1_sw_t feedback) {
	if (feedback == 0) { // Initial phase
		if (l == 0 && y < NUM_INPUTS) { // Input-Hidden layer
			return 0.06 + (get_random() / 50);
		} else if (l == OUTPUT_LAYER && xl < NUM_OUTPUTS) { // Hidden-Output layer
			return (get_random() / 10) - 0.05;
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

			// Iterate all pre-synaptic connections
			for (y = 0; y < NEURONS_PER_LAYER; y++) {

				// Process only non-null synapses
				if (l == OUTPUT_LAYER && xl < NUM_INPUTS) { // Output-Hidden

					float32_t t1 = exp_window(spiking_fr[previous_layer_idx + y], t_output_trials[trial_number]);
					float32_t t2 = exp_window(spiking_fr[previous_layer_idx + y], spiking_fr[x]);
					w_error[y][trial_number] = t1 - t2;
					synapse_weights[x][y] = get_new_weight(synapse_weights[x][y], t1 - t2);///((float32_t)NEURONS_PER_LAYER);

				} else if (l == 0 && y < NUM_INPUTS) { // Hidden-Hidden-Input

					// Collect propagated error
					float32_t t1 = exp_window(t_input_trials[trial_number], t_output_trials[trial_number]);
					float32_t t2 = exp_window(t_input_trials[trial_number], spiking_fr[x]);
					float32_t sum = (t1 - t2) * synapse_weights[post_layer_idx ][xl];
					w_error[x+NEURONS_PER_LAYER][trial_number] = sum;
					synapse_weights[x][y] = get_new_weight(synapse_weights[x][y], sum);
					//weights_delta[x][y] = sum/100;//((float32_t)NEURONS_PER_LAYER * (float32_t)NUM_INPUTS);
				}
			}
		}
	}
}

void generate_inputs() {
	uint32_t t = 0;
	for (int32_t k = 0; k < NUM_TRAINING_TRIALS; k++) {

		// Set input target output
		t_input_trials[k] = INPUT_FREQ;
		t_output_trials[k] =  OUTPUT_FREQ;

		// Store timing inputs
		float32_t acc = 2;
		for (int32_t x = 0; x < NUM_INPUTS; x++) {
			for (int32_t subt = 0; subt < TRIAL_TIME_MS; subt++, acc+=1) {
				if (acc >= INPUT_MS) {
					p_set_inputs[x][t + subt] = 1;
					acc = 0;
				} else p_set_inputs[x][t + subt] = 0;
			}
		}
		t += TRIAL_TIME_MS;
	}
}

void feedback_error(int32_t t) {

	if ((t % TRIAL_TIME_MS) == (TRIAL_TIME_MS - 1)) {
		int32_t t_start = t + 1 - TRIAL_TIME_MS;

		for (int32_t n = 0; n < NUMBER_OF_NEURONS; n++) {
			spiking_fr[n] = 0;//INFINITY;
			for (int32_t i = 0; i < TRIAL_TIME_MS; i++) {
				if (v_sw[((t_start + i) * NUMBER_OF_NEURONS) + n] >= 35.0f) {
					spiking_fr[n] ++;
				}
			}
			// Compute real firing rate
			spiking_fr[n] = spiking_fr[n] * (1000/TRIAL_TIME_MS);
		}

		// Refresh delta weights
		refresh_delta_weights();

		// Initialize global errors
		t_shift_error[trial_number] = 0;
		int32_t error = (int32_t)(spiking_fr[OUTPUT_NEURON] - t_output_trials[trial_number]);
		valid_trial ++;

		if (abs(error) <= THRESHOLD_FREQ) output_correct ++;

		firing_rates[trial_number] = spiking_fr[OUTPUT_NEURON];
		trial_success[trial_number] = (float32_t)output_correct/(float32_t)(valid_trial + 1);

		t_shift_error[trial_number] = abs(error); //t_shift_error_accum/(float32_t)(trial_number);

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
			fprintf(file1, "%d,%f,%f,%f,%f,%f,%f,%f", t, trial_success[t], t_shift_error[t], firing_rates[t], w_error[0][t], w_error[1][t], w_error[2][t], w_error[3][t]);
			#endif
			#if PERSIST_SW_RESULTS== RESULTS_FILE
			fprintf(file1, "\n");
			#endif
		}
		printf("Global output accuracy: %.3f\n", trial_success[NUM_TRAINING_TRIALS-2]);
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

#endif /* _SNN_NETWORK_SINGLE_H */
