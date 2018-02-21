################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

CPP_SRCS += \
C:/Users/fgalind1/Documents/Bristol/Thesis/Workspace/vivado/snn_izikevich/src/main_zynq.cpp 

OBJS += \
./src/main_zynq.o 

CPP_DEPS += \
./src/main_zynq.d 


# Each subdirectory must supply rules for building sources it contributes
src/main_zynq.o: C:/Users/fgalind1/Documents/Bristol/Thesis/Workspace/vivado/snn_izikevich/src/main_zynq.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: ARM g++ compiler'
	arm-xilinx-eabi-g++ -Wall -O3 -g3 -IC:/Xilinx/Vivado_HLS/2015.4/include -c -fmessage-length=0 -MT"$@" -mlittle-endian -I../../standalone_bsp_0/ps7_cortexa9_0/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


