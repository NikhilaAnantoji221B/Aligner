
///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_apb_tests_3_1_5.sv
// Author:      Dhanwanth
// Date:        2025-06-23
// Description: Test that sets checks RO mode behaviour for reserved fields.
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_APB_TESTS_3_1_5_SV
`define CFS_ALGN_APB_TESTS_3_1_5_SV

class cfs_algn_apb_tests_3_1_5 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_apb_tests_3_1_5)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_3_1_3 cfg_seq;
    //cfs_algn_virtual_sequence_rx_crt rx_seq;
    // cfs_algn_virtual_sequence_rx_err rx_err_seq2;
    cfs_algn_vif vif;

    uvm_reg_data_t read_val;
    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Fork forever slave responder
    fork
      begin
        cfs_md_sequence_tx_ready_block tx_block_seq = cfs_md_sequence_tx_ready_block::type_id::create(
            "tx_block_seq"
        );
        tx_block_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    cfg_seq = cfs_algn_virtual_sequence_3_1_3::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Wait a bit before sending traffic
    vif = env.env_config.get_vif();
    repeat (50) @(posedge vif.clk);


    $display("\n INITIAL CONFIGURATION OF REGS COMPLTD. WRITING RESERVED BITS!!!");

    env.model.reg_block.IRQEN.read(status, read_val, UVM_FRONTDOOR);
    // Attempt to write 1s into all bits including reserved
    env.model.reg_block.IRQEN.write(status, '1, UVM_FRONTDOOR);

    #(100ns);

    // writing into all the bits of ctrl reg to check behaviour of reserved
    // fields
    env.model.reg_block.CTRL.read(status, read_val, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.write(status, 32'hFFF_EFCFC, UVM_FRONTDOOR);
    ////////////////////////////////////////////////////////////////////////////////////////
    // Read-Only
    // A register field with this access type can only be read. A write attempt to such a register
    // field will not chance its value. But,
    // Any write access to a full read-only register must return an APB error.
    // Hence we will try to write into the status register to see if its
    // triggering an error.
    ////////////////////////////////////////////////////////////////////////////////////////

    env.model.reg_block.STATUS.read(status, read_val, UVM_FRONTDOOR);
    env.model.reg_block.STATUS.write(status, 32'hFFF_EFCFC, UVM_FRONTDOOR);

    ////////////////////////////////////////////////////////////////////////////////////////
    //The assertion of perr signal must be observed on the waveform
    ////////////////////////////////////////////////////////////////////////////////////////
    #(500ns);

    phase.drop_objection(this, "TEST_DONE");
  endtask

endclass

`endif
