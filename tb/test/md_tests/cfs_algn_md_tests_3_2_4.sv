///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_md_tests_3_2_4.sv
// Author:      Dhanwanth
// Date:        2025-06-23
// Description: To check is the controller can buffer data before sending it into the TX_FIFO
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_MD_TESTS_3_2_4_SV
`define CFS_ALGN_MD_TESTS_3_2_4_SV

class cfs_algn_md_tests_3_2_4 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_md_tests_3_2_4)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_crt1 rx_seq1;
    // cfs_algn_virtual_sequence_rx_err rx_err_seq2;
    cfs_algn_vif vif;

    uvm_reg_data_t reg_val;
    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Fork forever slave responder
    fork
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    vif = env.env_config.get_vif();
    repeat (50) @(posedge vif.clk);

    env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, reg_val, UVM_FRONTDOOR);
    #(100ns);

    for (int i = 0; i < 8; i++) begin
      rx_seq1 = cfs_algn_virtual_sequence_rx_crt1::type_id::create($sformatf("rx_seq1_%0d", i));
      rx_seq1.set_sequencer(env.virtual_sequencer);
      void'(rx_seq1.randomize());
      $display("\n*************************************************Sending %0d/8th packet*********************************************\n", i + 1);
      rx_seq1.start(env.virtual_sequencer);
      #(50ns);
    end

    #(100ns);
    phase.drop_objection(this, "TEST_DONE");
  endtask

endclass

`endif
