################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
C:/Users/fgalind1/Documents/Bristol/Thesis/Workspace/vivado/snn_izikevich/src/sw/snn_izikevich_sw.c 

OBJS += \
./src/sw/snn_izikevich_sw.o 

C_DEPS += \
./src/sw/snn_izikevich_sw.d 


# Each subdirectory must supply rules for building sources it contributes
src/sw/snn_izikevich_sw.o: C:/Users/fgalind1/Documents/Bristol/Thesis/Workspace/vivado/snn_izikevich/src/sw/snn_izikevich_sw.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM g++ compiler'
	arm-xilinx-eabi-g++ -Wall -O0 -g3 -IC:/Xilinx/Vivado_HLS/2015.4/include -c -fmessage-length=0 -MT"$@" -I../../standalone_bsp_0/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


