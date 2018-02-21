################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
C:/Users/fgalind1/Documents/Bristol/Thesis/Workspace/vivado/snn_izikevich/src/hw/zynq/platform.c 

OBJS += \
./src/hw/zynq/platform.o 

C_DEPS += \
./src/hw/zynq/platform.d 


# Each subdirectory must supply rules for building sources it contributes
src/hw/zynq/platform.o: C:/Users/fgalind1/Documents/Bristol/Thesis/Workspace/vivado/snn_izikevich/src/hw/zynq/platform.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM g++ compiler'
	arm-xilinx-eabi-g++ -Wall -O3 -g3 -IC:/Xilinx/Vivado_HLS/2015.4/include -c -fmessage-length=0 -MT"$@" -mlittle-endian -I../../standalone_bsp_0/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


