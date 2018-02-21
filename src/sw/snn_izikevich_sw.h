#ifndef _SNN_IZIKEVICH_SW_H_
#define _SNN_IZIKEVICH_SW_H_

#include "../common/snn_types.h"
#include "../common/snn_network.h"

// Neuron states
static  s_dat_sw_t 		synapse_s[NUMBER_OF_LAYERS][NEURONS_PER_LAYER];
static 	vu_dat_sw_t 	v[NUMBER_OF_NEURONS];
static 	vu_dat_sw_t 	u[NUMBER_OF_NEURONS];

/***************************************************************************
 *                              Prototypes                                 *
 ***************************************************************************/

void sw_snn_init();

void sw_snn_izikevich(
				uint1_sw_t neuron_type[NUMBER_OF_NEURONS][NEURONS_PER_LAYER],
				w_dat_sw_t synapse_weights[NUMBER_OF_NEURONS][NEURONS_PER_LAYER],
				uint1_sw_t p[INPUT_SYNAPSES],
				vu_dat_sw_t *v_output);


/***************************************************************************
 *                 Stage 1 (snn_update_neuron_synapses)                    *
 ***************************************************************************/
void sw_snn_update_neuron_synapses(uint1_sw_t p[INPUT_SYNAPSES]) {
	int32_t l, xl, x;

	for (x = 0, l = 0; l < NUMBER_OF_LAYERS; l++) for (xl = 0; xl < NEURONS_PER_LAYER; xl++, x++) {
		s_dat_sw_t new_synapse = synapse_s[l][xl] * (s_dat_sw_t)S_DECAY_FACTOR;

		if (l < NUMBER_OF_LAYERS - 1 && v[x] >= (vu_dat_sw_t)35.0f) // firing input (t-1)
			synapse_s[l][xl] = new_synapse + (s_dat_sw_t)1.0f;
		else if (l == NUMBER_OF_LAYERS - 1 && p[x-INPUT_SYNAPSE_OFFSET] == 1) // synaptic input
			synapse_s[l][xl] = new_synapse + (s_dat_sw_t)1.0f;
		else // only decay
			synapse_s[l][xl] = new_synapse;
	}
	return;
}

void sw_snn_update_izikevich_equations_by_neuron(
		uint32_t x, vu_dat_sw_t g_exh, vu_dat_sw_t g_inh, uint1_sw_t neuron_type) {

	vu_dat_sw_t dv, du;
	vu_dat_sw_t v_t = v[x];
	vu_dat_sw_t u_t = u[x];

	if (v_t < (vu_dat_sw_t)35.0f) { // Not firing
		vu_dat_sw_t IZH_A = (vu_dat_sw_t)IZHIKEVICH_A(neuron_type);
		vu_dat_sw_t IZH_B = (vu_dat_sw_t)IZHIKEVICH_B;

		vu_dat_sw_t I = (g_exh * ((vu_dat_sw_t)ES_EXCITATORY - v_t)) + (g_inh * ((vu_dat_sw_t)ES_INHIBITORY - v_t));

		// First 0.5 ms
		dv = ((((vu_dat_sw_t)0.04f * v_t) + (vu_dat_sw_t)5.0f) * v_t) + (vu_dat_sw_t)140.0f - u_t + I;
		du = IZH_A * ((IZH_B * v_t) - u_t);
		v_t = v_t + (dv * ((vu_dat_sw_t)TIMESTEP_MS));
		u_t = u_t + (du * ((vu_dat_sw_t)TIMESTEP_MS));

		// Second 0.5 ms
		dv = ((((vu_dat_sw_t)0.04f * v_t) + (vu_dat_sw_t)5.0f) * v_t) + (vu_dat_sw_t)140.0f - u_t + I;
		du = IZH_A * ((IZH_B * v_t) - u_t);
		v_t = v_t + (dv * ((vu_dat_sw_t)TIMESTEP_MS));
		v_t =  v_t > (vu_dat_sw_t)35.0f? (vu_dat_sw_t)35.0f : v_t;

		// Persist results
		v[x] = v_t;
		u[x] = u_t + (du * ((vu_dat_sw_t)TIMESTEP_MS));
	}
	else { // Firing
		v[x] = (vu_dat_sw_t)IZHIKEVICH_C;
		u[x] = u_t + ((vu_dat_sw_t)IZHIKEVICH_D(neuron_type));
	}
}

/***************************************************************************
 *                 Stage 2 (snn_get_synaptic_conductances)                 *
 ****************************x***********************************************/
void sw_snn_get_synaptic_conductances(
		uint1_sw_t neuron_type[NUMBER_OF_LAYERS][NEURONS_PER_LAYER],
		w_dat_sw_t synapse_weights[NUMBER_OF_NEURONS][NEURONS_PER_LAYER],
		vu_dat_sw_t v_output[NUMBER_OF_NEURONS]) {

	// Temporal indexes and cache
	uint32_t y, xl, l, x;

	for (x = 0, l = 0; l < NUMBER_OF_LAYERS; l++) for (xl = 0; xl < NEURONS_PER_LAYER; xl++, x++) {

		int32_t l_pre = (l==0 ? NUMBER_OF_LAYERS-1 : l - 1);
		vu_dat_sw_t sum_g_exh = 0;
		vu_dat_sw_t sum_g_inh = 0;

		// Perform sum of synaptic conductances per neuron
		for (y = 0; y < NEURONS_PER_LAYER; y++) {

			if (l == 0 || neuron_type[l_pre][y] == EXCITATORY_NEURON)
				sum_g_exh += synapse_weights[x][y] * synapse_s[l_pre][y];
			else
				sum_g_inh += synapse_weights[x][y] * synapse_s[l_pre][y];
		}

		// Update izikevich's equations
		sw_snn_update_izikevich_equations_by_neuron(x, sum_g_exh, sum_g_inh, neuron_type[l][xl]);
		v_output[x] = v[x];
	}
	return;
}

/***************************************************************************
 *                       Wrapper (snn_process_step)                        *
 ***************************************************************************/
void sw_snn_izikevich(
				uint1_sw_t neuron_type[NUMBER_OF_NEURONS][NEURONS_PER_LAYER],
				w_dat_sw_t synapse_weights[NUMBER_OF_NEURONS][NEURONS_PER_LAYER],
				uint1_sw_t p[INPUT_SYNAPSES],
				vu_dat_sw_t *v_output) {

	// Compute neuron synapses for all neurons
	sw_snn_update_neuron_synapses(p);

	// Compute matrix of synaptic conductances
	sw_snn_get_synaptic_conductances(neuron_type, synapse_weights, v_output);
}


void sw_snn_init() {
	int32_t x;
	for (x = 0; x < NUMBER_OF_NEURONS; x++) {
		v[x] = -70.0; //resting potential
		u[x] = -14.0; //steady state
	}
}

#endif /* _SNN_IZIKEVICH_SW_H_ */
