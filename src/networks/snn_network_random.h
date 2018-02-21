#ifndef _SNN_NETWORK_RANDOM_H
#define _SNN_NETWORK_RANDOM_H

// Common libraries
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "../snn_config.h"
#include "../common/snn_types.h"
#include "../common/snn_network.h"
#include "snn_network_defs.h"

#if APP_TYPE == APP_RANDOM

// Common interface
uint1_sw_t get_neuron_type(int32_t l, int32_t xl);
uint1_sw_t get_spike(int32_t t, int32_t x);
float32_t get_weight(int32_t l, int32_t xl, int32_t x, int32_t y, uint1_sw_t feedback);

// Specialized methods/variables
static uint1_sw_t	p_random[RUN_STEPS * INPUT_SYNAPSES];
void generate_inputs();

// Methods

void generate_inputs() {
	int32_t t;
	uint1_sw_t *ptr_p = p_random;
	for (t = 0; t < RUN_STEPS; t++) {
		int32_t x;
		// Possion distribution of firing inputs
		for (x = 0; x < INPUT_SYNAPSES; x++) {
			ptr_p[x] = 0;
			//uint1_sw_t fired = get_random() < INPUT_FIRING_RATE;
			uint1_sw_t fired = t%20 == 0;
			if (t > 0 && t < (RUNTIME_MS - INPUT_FIRINGS_OFFSET) && fired)
				ptr_p[x] = 1;
		}
		ptr_p += INPUT_SYNAPSES;
	}
}

uint1_sw_t get_neuron_type(int32_t l, int32_t xl) {
	return get_random() < PROBABILITY_INHIBITORY_NEURON;
}

uint1_sw_t get_spike(int32_t t, int32_t x) {
	return p_random[(t * INPUT_SYNAPSES) + x];
}

float32_t get_weight(int32_t l, int32_t xl, int32_t x, int32_t y, uint1_sw_t feedback) {
	float32_t weight;
	if (x < NEURONS_PER_LAYER) { // Set input weight
		if (y >= INPUT_SYNAPSES) weight = 0;
		else if (get_random() <= INPUT_SYNAPSE_PROBABILITY) weight = INPUT_SYNAPSE_WEIGHT;
		else weight = 0;
	} else { // Layer synapse's weight
		if (get_random() <= INTER_CONNECTION_PROBABILITY) {
			weight = SYNAPSE_WEIGHT;
			if (neuron_type[l][xl] == INHIBITORY_NEURON) weight *= 2;
		} else weight = 0;
	}
	return weight;
}

#endif /* APP_TYPE */

#endif /* _SNN_NETWORK_RANDOM_H */
