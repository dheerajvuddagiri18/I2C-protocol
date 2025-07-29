# I2C-protocol
FSM implementation of master and slave of I2C protocol in Verilog
# I2C-protocol

This repository provides a comprehensive FSM (Finite State Machine) implementation of both the master and slave components of a simple I2C (Inter-Integrated Circuit) protocol in Verilog. It is designed for educational purposes, simulation, and can be used as a reference for hardware or FPGA-based I2C communication systems.

## Features

- **Verilog Implementation:** Complete source code of I2C master and slave modules written in Verilog, following the I2C protocol specification.
- **FSM-Based Design:** Both master and slave modules use clear FSMs for protocol state handling, ensuring robust and structured communication.
- **Bidirectional Communication:** Demonstrates both write and read operations between master and slave, including ACK/NACK generation, start/stop conditions, address phase, and data phase.
- **Tri-State Data Lines:** Correct usage of tri-state logic for the SDA line to allow bidirectional data transfer as per I2C standards.
- **Parameterization:** Easily modifiable parameters such as I2C address, data width, and stored data for flexible experimentation.
- **Testbench Included:** Includes a detailed testbench (`i2c_tb.v`) for simulating I2C transactions, verifying correct operation, and showcasing waveform generation.
- **Example Slave Address & Data:** Pre-configured slave address and data in `i2c_slave.v` for immediate experimentation and demonstration.

## Repository Contents

- **i2c_master.v**  
  Implements the I2C master logic, handling:
  - Generation of SCL (Serial Clock Line) and management of SDA (Serial Data Line)
  - FSM states: IDLE, START, ADDRESS,READ_ACK1, DATA_TRANSFER,WRITE_ACK,READ_ACK2,STOP.
  - Read/Write control, busy signaling, asynchronous reset, and data latching
  - Output tri-state control for the SDA line
  - Parameterized I2C timing and operation

- **i2c_slave.v**  
  Implements the I2C slave logic, including:
  - FSM states : READ_ADDRESS, SEND_ACK1, DATA_TRANSFER, SEND_ACK2.
  - Comparison and matching of incoming address against the predefined slave address
  - Handling read and write requests from the master, including data latching and output
  - Sending ACK/NACK responses to the master
  - Tri-state control of the SDA line to avoid bus contention

- **i2c_tb.v**  
  A testbench module to verify and simulate I2C communication between the master and slave:
  - Generates clock and reset signals
  - Instantiates both master and slave modules and connects their I2C lines
  - Sequences write and read operations, toggles enables, and displays results
  - Demonstrates correct operation using example address and data

- **README.md**  
  This documentation file.

## How It Works

1. **Master Initiation:** The master asserts a start condition, sends the 7-bit address + R/W bit, and waits for ACK from the slave.
2. **Address Matching:** The slave checks the received address and sends an ACK if it matches its own.
3. **Data Transfer:**
    - **Write Operation:** Master sends data to the slave, which latches it and responds with ACK.
    - **Read Operation:** Master receives data from the slave and sends ACK/NACK to indicate more data or stop.
4. **Stop Condition:** The master asserts a stop condition to end the transaction.

## Applications

- FPGA-based I2C controller development
- Educational demonstration of I2C protocol internals
- Simulation and verification of I2C communication
- Reference design for custom hardware projects

## Getting Started

1. Clone the repository.
2. Use any Verilog simulator (e.g., ModelSim, Icarus Verilog, Vivado) to run `i2c_tb.v`.
3. Modify slave address/data or testbench parameters as needed for experimentation.

## Notes

- The modules are parameterized for easy adaptation.
- The code is written for clarity and educational value; optimizations for production hardware can be added as needed.
- No external dependencies are required beyond a Verilog simulation environment.

