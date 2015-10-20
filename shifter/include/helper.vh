`ifndef __HELPER_H__
`define __HELPER_H__

// Need to define BIT at first.
// BIT = Your DATA_WIDTH

`define NAME(x) mips``x``_shift_mux
`define shift_inst_helper(r, s, in, out)\
`NAME(`BIT) rank``r (\
    .switch(s``r),\
    .shift0(in),\
    .shift1({in[`BIT - 1 - r : 0], r'd0}),\
    .shift2({{r{sign}}, in[`BIT - 1 : r]}),\
    .shift3({in[r - 1 : 0], in[`BIT - 1 : r]}),\
    .shift_out(out)\
)

`endif
