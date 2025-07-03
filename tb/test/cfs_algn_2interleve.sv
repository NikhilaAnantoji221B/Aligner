
`ifndef CFS_ALGN_2INYERLEVE_SV
`define CFS_ALGN_2INTERLEVE_SV

class cfs_algn_2interleve extends cfs_algn_test_base;

  `uvm_component_utils(cfs_algn_2interleve)

  function new(string name = "", uvm_component parent = null);

    super.new(name, parent);

  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;

    cfs_algn_virtual_sequence_reg_config cfg_seq;

    cfs_algn_virtual_sequence_rx rx_seq;
    cfs_algn_virtual_sequence_rx_err rx_seq_err;


    cfs_algn_vif vif;

    uvm_reg_data_t control_val;
    uvm_reg_data_t status_val;
    uvm_reg_data_t irqen_val;

    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");

    #(100ns);

    // Step 0: Fork slave response forever

    fork

      begin

        resp_seq = cfs_md_sequence_slave_response_forever::type_id::create("resp_seq");

        resp_seq.start(env.md_tx_agent.sequencer);

      end

    join_none

    // Step 1: Register config
    cfg_seq = cfs_algn_virtual_sequence_reg_config::type_id::create("cfg_seq");

    cfg_seq.set_sequencer(env.virtual_sequencer);

    cfg_seq.start(env.virtual_sequencer);


    env.model.reg_block.IRQEN.read(status, irqen_val, UVM_FRONTDOOR);
    irqen_val = 32'h0000001f;  // enabling all interupts
    env.model.reg_block.IRQEN.write(status, irqen_val, UVM_FRONTDOOR);
    `uvm_info("2INTERLEVE", $sformatf("IRQEN enabled: 0x%0h", irqen_val),
              UVM_MEDIUM)  //ensure irqen value=1f


    // Step 2: Manual CTRL config-valid config size-4,offset-0

    env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, control_val, UVM_FRONTDOOR);

    `uvm_info("2INTERLEVE", $sformatf("CTRL register value: 0x%0h", control_val), UVM_MEDIUM)

    // Step 3: Wait post reset
    vif = env.env_config.get_vif();

    repeat (50) @(posedge vif.clk);

    // Step 4: Send 1 RX packet, delay 5 clks, read STATUS at each negedge

    for (int i = 0; i < 1; i++) begin
      rx_seq = cfs_algn_virtual_sequence_rx::type_id::create($sformatf("rx_size1_%0d", i));
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
      #(5ns);
      @(negedge vif.clk);
      env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
      `uvm_info("2INTERLEVE", $sformatf("Status reg value = %0d", status_val), UVM_MEDIUM)
    end
    //Step 5:Send 1 Illegal RX packet 
    for (int i = 0; i < 1; i++) begin
      rx_seq_err = cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_size1_%0d", i));
      rx_seq_err.set_sequencer(env.virtual_sequencer);
      void'(rx_seq_err.randomize());
      rx_seq_err.start(env.virtual_sequencer);
      #(5ns);
      @(negedge vif.clk);
      env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
      `uvm_info("2INTERLEVE", $sformatf("Status reg value = %0d", status_val), UVM_MEDIUM)
    end
    //Invalid ctrl.size =3,ctrl.offset=1
    env.model.reg_block.CTRL.write(status, 32'h00000103, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, control_val, UVM_FRONTDOOR);
    // Step 4: Send 1 RX packet, delay 5 clks, read STATUS at each negedge

    for (int i = 0; i < 1; i++) begin
      rx_seq = cfs_algn_virtual_sequence_rx::type_id::create($sformatf("rx_size1_%0d", i));
      rx_seq.set_sequencer(env.virtual_sequencer);
      void'(rx_seq.randomize());
      rx_seq.start(env.virtual_sequencer);
      #(5ns);
      @(negedge vif.clk);
      env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
      `uvm_info("2INTERLEVE", $sformatf("Status reg value = %0d", status_val), UVM_MEDIUM)
    end
    //Step 5:Send 1 Illegal RX packet 
    for (int i = 0; i < 1; i++) begin
      rx_seq_err = cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_size1_%0d", i));
      rx_seq_err.set_sequencer(env.virtual_sequencer);
      void'(rx_seq_err.randomize());
      rx_seq_err.start(env.virtual_sequencer);
      #(5ns);
      @(negedge vif.clk);
      env.model.reg_block.STATUS.read(status, status_val, UVM_FRONTDOOR);
      `uvm_info("2INTERLEVE", $sformatf("Status reg value = %0d", status_val), UVM_MEDIUM)
    end





    #(200ns);

    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif


