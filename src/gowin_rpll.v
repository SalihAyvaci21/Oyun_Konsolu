// Gowin_rPLL.v
module Gowin_rPLL (clkout, clkoutd, clkin, lock);
    output clkout;
    output clkoutd;
    input clkin;
    output lock;

    wire gw_gnd = 1'b0;

    rPLL rpll_inst (
        .CLKOUT(clkout),
        .LOCK(lock),
        .CLKOUTD(clkoutd),
        .RESET(gw_gnd),
        .RESET_P(gw_gnd),
        .CLKIN(clkin),
        .CLKFB(gw_gnd),
        .FBDSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .IDSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .ODSEL({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .PSDA({gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .DUTYDA({gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
        .FDLY({gw_gnd,gw_gnd,gw_gnd,gw_gnd})
    );

    // PARAMETRELER: 9MHz çıkış için IDE'den ayarlanmalı
    defparam rpll_inst.FCLKIN = "27";
    defparam rpll_inst.DEVICE = "GW1NR-9C";
    defparam rpll_inst.CLKOUTD_SRC = "CLKOUT";
endmodule

// Gowin_OSC.v (Bu projede XTAL kullandığımız için şart değil ama isterseniz)
module Gowin_OSC (oscout);
    output oscout;
    OSC osc_inst (.OSCOUT(oscout));
    defparam osc_inst.FREQ_DIV = 10;
    defparam osc_inst.DEVICE = "GW1NR-9C";
endmodule