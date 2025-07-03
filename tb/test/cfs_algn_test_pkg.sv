///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_test_pkg.sv
// Author:      Cristian Florin Slav
// Date:        2023-06-27
// Description: Test package.
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_TEST_PKG_SV
`define CFS_ALGN_TEST_PKG_SV 

`include "uvm_macros.svh"
`include "../env/cfs_algn_pkg.sv"

package cfs_algn_test_pkg;
  import uvm_pkg::*;
  import cfs_algn_pkg::*;
  import cfs_apb_pkg::*;
  import cfs_md_pkg::*;

  `include "cfs_algn_test_defines.sv"
  `include "cfs_algn_test_base.sv"
  `include "cfs_algn_test_reg_access.sv"
  `include "cfs_algn_test_random.sv"

  `include "cfs_algn_test_clr_1write1.sv"
  `include "cfs_algn_test_1reg_access.sv"
  `include "cfs_algn_test_1fifo_lvls.sv"
  `include "cfs_algn_2data_algn.sv"
  `include "cfs_algn_2interleve.sv"
  `include "cfs_algn_intr_test.sv"

  //manual apb tests included below
  `include "../test/apb_tests/cfs_algn_apb_tests_mapped_unmapped.sv"

  //manual md tests included below
  `include "../test/md_tests/cfs_algn_md_tests_random_traffic.sv"
  `include "../test/md_tests/cfs_algn_md_tests_cnt_drop.sv"
endpackage

`endif
