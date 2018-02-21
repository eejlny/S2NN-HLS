<project xmlns="com.autoesl.autopilot.project" name="hls" top="hls_snn_izikevich">
    <includePaths/>
    <libraryPaths/>
    <Simulation argv="">
        <SimFlow name="csim" setup="true" csimMode="2" lastCsimMode="2"/>
    </Simulation>
    <files xmlns="">
        <file name="../../src/main_hls.cpp" sc="0" tb="1" cflags=" "/>
        <file name="../../src/hw/snn_izikevich_hw_sim.h" sc="0" tb="1" cflags=" "/>
        <file name="../../src/sw/snn_izikevich_sw.h" sc="0" tb="1" cflags=" "/>
        <file name="../../src/networks/snn_network_adder.h" sc="0" tb="1" cflags=" "/>
        <file name="../../src/networks/snn_network_defs.h" sc="0" tb="1" cflags=" "/>
        <file name="../../src/networks/snn_network_pattern.h" sc="0" tb="1" cflags=" "/>
        <file name="../../src/networks/snn_network_random.h" sc="0" tb="1" cflags=" "/>
        <file name="../../src/networks/snn_network_xor.h" sc="0" tb="1" cflags=" "/>
        <file name="../../src/common/snn_results.h" sc="0" tb="1" cflags=" "/>
        <file name="../../src/common/snn_start.h" sc="0" tb="1" cflags=" "/>
        <file name="src/common/snn_types.h" sc="0" tb="false" cflags=""/>
        <file name="src/common/snn_network.h" sc="0" tb="false" cflags=""/>
        <file name="src/hw/snn_izikevich_top.cpp" sc="0" tb="false" cflags=""/>
        <file name="src/hw/snn_izikevich_axi.h" sc="0" tb="false" cflags=""/>
        <file name="src/hw/snn_izikevich.h" sc="0" tb="false" cflags=""/>
        <file name="src/common/snn_env.h" sc="0" tb="false" cflags=""/>
        <file name="src/common/snn_defs.h" sc="0" tb="false" cflags=""/>
        <file name="src/snn_config.h" sc="0" tb="false" cflags=""/>
    </files>
    <solutions xmlns="">
        <solution name="solution" status="active"/>
    </solutions>
</project>

