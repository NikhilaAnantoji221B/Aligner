//Test to hit all possible valid combinations of md and ctrl, size and offset
`ifndef CFS_ALGN_TEST_SIZE_OFFSET_CROSS_RESET_SV
`define CFS_ALGN_TEST_SIZE_OFFSET_CROSS_RESET_SV

class cfs_algn_test_size_offset_cross_reset extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_test_size_offset_cross_reset)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual cfs_apb_if vif_apb;
  virtual cfs_algn_if vif_algn;
  uvm_status_e status;
  process resp_proc;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual cfs_apb_if)::get(
            null, "uvm_test_top.env.apb_agent", "vif", vif_apb
        )) begin
      `uvm_fatal("NO_VIF", "Unable to get APB vif")
    end
    if (!uvm_config_db#(virtual cfs_algn_if)::get(null, "uvm_test_top.env", "vif", vif_algn)) begin
      `uvm_fatal("NO_ALGN_VIF", "Unable to get ALGN vif")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_rx_comb rx_comb_seq;
    cfs_algn_virtual_sequence_reg_config reg_cfg;
    int i;
    int ctrl_val_list[] = '{
        32'h00000000,  // size=0, offset=0
        32'h00000001,  // size=1, offset=0
        32'h00000101,  // size=1, offset=1
        32'h00000201,  // size=1, offset=2
        32'h00000301,  // size=1, offset=3
        32'h00000002,  // size=2, offset=0
        32'h00000202,  // size=2, offset=2
        32'h00000203,  // size=3, offset=2
        32'h00000004  // size=4, offset=0
    };
    phase.raise_objection(this, "Start size-offset cross test with reset");
    #(10ns)
    // Start slave responder
    fork
      resp_proc = process::self();
      begin
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");
        resp_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    //#(10ns);
    // Do initial register config
    reg_cfg = cfs_algn_virtual_sequence_reg_config::type_id::create("reg_cfg");
    void'(reg_cfg.randomize());
    reg_cfg.set_sequencer(env.virtual_sequencer);
    reg_cfg.start(env.virtual_sequencer);

    foreach (ctrl_val_list[i]) begin
      // --- Assert Reset ---
      repeat (2) @(posedge vif_algn.clk);
      `uvm_info("CTRL_INFO", $sformatf(
                "--------------------------------------------------Asserting reset before CTRL = 0x%0h",
                ctrl_val_list[i]
                ), UVM_MEDIUM)
      vif_apb.preset_n <= 0;
      repeat (2) @(posedge vif_algn.clk);

      // Kill responder temporarily (optional)
      resp_proc.kill();

      repeat (2) @(posedge vif_algn.clk);
      vif_apb.preset_n <= 1;
      `uvm_info(get_type_name(), "Deasserted reset", UVM_MEDIUM)

      // Restart responder
      fork
        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq_post_reset");
        resp_seq.start(env.md_tx_agent.sequencer);
      join_none

      // --- Program CTRL Register ---
      @(posedge vif_algn.clk);
      env.model.reg_block.CTRL.write(status, ctrl_val_list[i], UVM_FRONTDOOR);

      $display(
          "CTRL_INFO: --------------------------------------------------Asserting reset before CTRL = 0x%08h",
          ctrl_val_list[i]);
      // --- Start RX Combination Sequence ---
      rx_comb_seq = cfs_algn_virtual_sequence_rx_comb::type_id::create("rx_comb_seq");
      rx_comb_seq.set_sequencer(env.virtual_sequencer);
      rx_comb_seq.start(env.virtual_sequencer);

      // Wait for model to consume data
      while (env.model.is_empty()) @(posedge vif_algn.clk);
    end

    #(100ns);
    phase.drop_objection(this, "End of size-offset cross test with reset");
  endtask

endclass

`endif
