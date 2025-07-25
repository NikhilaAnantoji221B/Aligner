`ifndef CFS_ALGN_TXEMPTY_TRIGGER_SV
`define CFS_ALGN_TXEMPTY_TRIGGER_SV
class cfs_algn_txempty_trigger extends cfs_algn_test_base;
  `uvm_component_utils(cfs_algn_txempty_trigger)

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    cfs_md_sequence_slave_response_forever resp_seq;
    cfs_algn_virtual_sequence_reg_config cfg_seq;
    cfs_algn_virtual_sequence_rx_err rx_err_seq;
    cfs_algn_virtual_sequence_rx_size4_offset0 rx_non_err_seq;
    cfs_algn_virtual_sequence_rx_size4_offset0 data_40seq;
    cfs_algn_vif vif;
    uvm_reg_data_t irqen_val;
    uvm_reg_data_t cnt_val;
    uvm_reg_data_t clr_val;
    uvm_reg_data_t irq_val;
    uvm_status_e status;

    phase.raise_objection(this, "TEST_START");

    #(100ns);


    // Step 0: Fork SLAVE_RESPONSE_FOREVER

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
    // irqen_val[4] = 1'b1;  // MAX_DROP
    env.model.reg_block.IRQEN.write(status, 32'h0000001f, UVM_FRONTDOOR);
    `uvm_info("1WRITE1", $sformatf("IRQEN updated: 0x%0h", irqen_val),
              UVM_MEDIUM)  //ensure irqen_val[4]=1

    // Step 2: Manual CTRL config - offset 0 size 4 

    env.model.reg_block.CTRL.write(status, 32'h00000004, UVM_FRONTDOOR);
    env.model.reg_block.CTRL.read(status, cnt_val, UVM_FRONTDOOR);

    `uvm_info("clr_1write1", $sformatf("CTRL register value: 0x%0h yes", cnt_val), UVM_MEDIUM)

    // Step 3: wait
    vif = env.env_config.get_vif();

    repeat (50) @(posedge vif.clk);
    // sending 258 illegal data from rx

    for (int i = 0; i < 258; i++) begin

      rx_err_seq = cfs_algn_virtual_sequence_rx_err::type_id::create($sformatf("rx_size1_%0d", i));

      rx_err_seq.set_sequencer(env.virtual_sequencer);

      void'(rx_err_seq.randomize());

      rx_err_seq.set_sequencer(env.virtual_sequencer);

      rx_err_seq.start(env.virtual_sequencer);

    end

    // `uvm_

    repeat (50) @(posedge vif.clk);

    data_40seq =
        cfs_algn_virtual_sequence_rx_size4_offset0::type_id::create($sformatf("rx_size1_"));

    data_40seq.set_sequencer(env.virtual_sequencer);

    void'(data_40seq.randomize());

    data_40seq.set_sequencer(env.virtual_sequencer);

    data_40seq.start(env.virtual_sequencer);

    repeat (10) @(posedge vif.clk);


    irqen_val = 32'h00000000;  // MAX_DROP

    env.model.reg_block.IRQ.write(status, irqen_val, UVM_FRONTDOOR);

    #(30ns);

    // `uvm_info("TEST_INTERRUPT", $sformatf("IRQEN updated: 0x%0h", irqen_val),

    env.model.reg_block.IRQ.read(status, irqen_val, UVM_FRONTDOOR);

    // sending 258 illegal data from rx
    #(5000ns);
    phase.drop_objection(this, "TEST_DONE");

  endtask

endclass

`endif


