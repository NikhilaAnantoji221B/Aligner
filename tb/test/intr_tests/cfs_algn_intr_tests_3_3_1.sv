///////////////////////////////////////////////////////////////////////////////
// File:        cfs_algn_intr_tests_3_3_1.sv
// Author:      Dhanwanth
// Date:        2025-06-23
// Description: CNT_DROP Max detection
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_ALGN_INTR_TESTS_3_3_1_SV
`define CFS_ALGN_INTR_TESTS_3_3_1_SV

class cfs_algn_intr_tests_3_3_1 extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_intr_tests_3_3_1)

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_3_1_1 cfg_seq;
    cfs_algn_virtual_sequence_rx_err rx_err_seq1;
    cfs_algn_virtual_sequence_rx_err rx_err_seq2;
    cfs_algn_vif vif;

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

    // Step 1: Configure MAX_DROP
    cfg_seq = cfs_algn_virtual_sequence_3_1_1::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    // Step 2: Wait a bit before sending traffic
    vif = env.env_config.get_vif();
    repeat (50) @(posedge vif.clk);

    // Step 3: Send 200 illegal RX packets
    for (int i = 0; i < 260; i++) begin
      rx_err_seq1 =
          cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_err_seq_%0d", i));
      rx_err_seq1.set_sequencer(env.virtual_sequencer);
      void'(rx_err_seq1.randomize());
      rx_err_seq1.start(env.virtual_sequencer);
    end

    #(500ns);

    phase.drop_objection(this, "TEST_DONE");
  endtask

endclass

`endif
