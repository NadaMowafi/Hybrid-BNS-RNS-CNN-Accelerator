# RNS CNN Accelerator

A research-oriented implementation of a hybrid CNN accelerator using the Residue Number System (RNS) for convolution operations while keeping the remaining network layers in the conventional binary domain.

The project investigates partial RNS-based neural network acceleration, where the computationally intensive convolution layers are executed in the residue domain to exploit parallel modular arithmetic and reduce arithmetic complexity.

---

# Overview

This repository explores:

- Partial RNS-based CNN inference
- RNS convolution acceleration
- Quantized CNN inference
- Binary-to-RNS conversion
- RNS arithmetic modules
- Hardware-oriented CNN implementation
- Verification against conventional binary CNN outputs

The current architecture performs:

- Convolution layers → RNS domain
- Remaining layers (ReLU, Pooling, FC) → Binary domain

This allows evaluation of the benefits and overheads of partial RNS acceleration before moving toward fully end-to-end RNS neural networks.

---

# Project Motivation

Convolution operations dominate the computational cost of CNN inference due to the large number of multiply-accumulate (MAC) operations.

Residue Number Systems offer:

- Carry-free arithmetic
- High parallelism
- Modular computation
- Potential improvements in:
  - Throughput
  - Energy efficiency
  - Hardware scalability

However, non-modular operations remain challenging in RNS systems.  
This project focuses on accelerating only the convolution layers while maintaining compatibility with standard neural network pipelines.

---

# Architecture

Input Image
    ↓
Quantization
    ↓
Binary to RNS Conversion
    ↓
RNS Convolution Engine
    ↓
RNS to Binary Reconstruction
    ↓
ReLU / Pooling / FC Layers (Binary Domain)
    ↓
Classification Output

---

# Features

- CNN training in PyTorch
- Weight and activation quantization
- Partial RNS inference pipeline
- Multi-moduli RNS representation
- RNS convolution validation
- Integer vs RNS output comparison
- Verilog hardware modules
- FPGA-oriented architecture exploration

---

# Current Status

Implemented:
- Baseline CNN training
- Quantized parameter export
- Partial RNS convolution simulation
- BNS ↔ RNS conversion modules
- Modular arithmetic blocks
- Verilog validation testbenches

In Progress:
- Full Conv layer acceleration
- FPGA synthesis flow
- Performance benchmarking
- Latency and resource analysis

Planned:
- RRNS error detection
- End-to-end RNS pipeline
- Ternary/RNS exploration
- Photonic-RNS integration concepts

---

# Technologies

Software:
- Python
- PyTorch
- NumPy

Hardware:
- Verilog HDL
- ModelSim
- FPGA workflow

---

# Example Moduli Sets

Example low-cost moduli sets used in experiments:

```text
{32749, 65521}
