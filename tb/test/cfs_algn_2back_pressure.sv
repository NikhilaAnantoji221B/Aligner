`ifndef CFS_ALGN_2BACK_PRESSURE_SV
`define CFS_ALGN_2BACK_PRESSURE_SV
class cfs_algn_2back_pressure extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_2back_pressure)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    // cfs_algn_virtual_sequence_rx rx_seq;
    cfs_algn_virtual_sequence_rx_size4_offset0 rx_seq40;
    cfs_md_sequence_md_tx_ready_block txblock_seq;
    cfs_algn_vif vif;
    uvm_reg_data_t irqen_val;
    uvm_reg_data_t control_val;
    uvm_reg_data_t status_val;
    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");

    #(100ns);


    // Step 0: Fork SLAVE_RESPONSE_FOREVER

    fork
      begin
        txblock_seq = cfs_md_sequence_md_tx_ready_block::type_id::create("txblock_seq");
        txblock_seq.start(env.md_tx_agent.sequencer);
      end
    join_none

    //1. Register config
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");
    cfg_seq.set_sequencer(env.virtual_sequencer);
    cfg_seq.start(env.virtual_sequencer);

    //2.Enable all interupts
    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val = 32'h0000001f;  // enabling all interupts
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    `uvm_info("1FIFO_LVLS", $sformatf("IRQEN updated: 0x%0h", irqen_val),
              UVM_MEDIUM)  //ensure irqen value=1f

    // Step 3: Manual CTRL config - offset 0 size 4 

    env.model.reg_block.CTRL.write(status, 32'h00000001, UVM_FRONTDOOR);
    #(20ns);
    env.model.reg_block.CTRL.read(status, control_val, UVM_FRONTDOOR);

    `uvm_info("clr_1write1", $sformatf("CTRL register value: 0x%0h yes", control_val), UVM_MEDIUM)


    vif = env.env_config.get_vif();

    repeat (50) @(posedge vif.clk);

    // Step 4: Send 2 RX packets 

    for (int i = 0; i < 11; i++) begin
      rx_seq40 =
          cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size1_%0d", i));

      rx_seq40.set_sequencer(env.virtual_sequencer);
      void'(rx_seq40.randomize());

      rx_seq40.start(env.virtual_sequencer);
      //@(negedge vif.clk);
      #(50ns);
      env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
      //   env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);


    end



    //  `uvm_info("1WRITE1", $sformatf("IRQEN updated: 0x%0h", cnt_val[7:0]),UVM_MEDIUM)  //ensure irqen_val[4]=1
    #(1000ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif


