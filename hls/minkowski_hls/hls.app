<AutoPilot:project xmlns:AutoPilot="com.autoesl.autopilot.project" top="predict_kernel" name="minkowski_hls" ideType="classic">
    <files>
        <file name="src/fpga_kernels.cpp" sc="0" tb="false" cflags="-I/home/zzh/minkowski_fpga/hls/include" csimflags="" blackbox="false"/>
        <file name="/home/zzh/minkowski_fpga/hls/src/dump.cpp" sc="0" tb="1" cflags="-I/home/zzh/minkowski_fpga/hls/include -Wno-unknown-pragmas" csimflags="" blackbox="false"/>
        <file name="/home/zzh/minkowski_fpga/hls/src/zonotope_operations.cpp" sc="0" tb="1" cflags="-I/home/zzh/minkowski_fpga/hls/include -Wno-unknown-pragmas" csimflags="" blackbox="false"/>
        <file name="/home/zzh/minkowski_fpga/hls/src/testbench.cpp" sc="0" tb="1" cflags="-I/home/zzh/minkowski_fpga/hls/include -Wno-unknown-pragmas" csimflags="" blackbox="false"/>
    </files>
    <solutions>
        <solution name="sol1" status=""/>
    </solutions>
    <Simulation argv="">
        <SimFlow name="csim" setup="false" optimizeCompile="false" clean="false" ldflags="" mflags=""/>
    </Simulation>
</AutoPilot:project>
