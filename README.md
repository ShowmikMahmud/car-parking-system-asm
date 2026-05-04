# 🚗 Advanced Car Parking & Slot Management System

> **Course:** Microprocessor
> **Language:** Assembly Language (EMU 8086)
> **University:** BRAC University
> **Project Type:** Group Final Project

---

## 📋 Project Overview

A fully functional **software-based Car Parking & Slot Management System** built entirely in x86 Assembly Language using EMU 8086. The system simulates a real-world parking management environment with role-based access, automated slot allocation, vehicle tracking, and billing.

---

## ✨ Features

### Feature 1 — Menu + Slot Allocation + Overflow Handling
- Terminal-style menu interface with continuous loop
- Array-based slot tracking
- Automatically finds and assigns the first available slot
- Detects when all 10 slots are full and blocks check-in

### Feature 2 — Multi-Role Access with PIN Protection
- Gate Operator Mode — Check-In, Check-Out, Search vehicles
- Owner Mode — PIN protected (default: 1234) with * masking
- Owner Dashboard: Total Revenue, Total Cars, Slot Statistics

### Feature 3 — Variable-Length Plate Registration (Stack)
- Uses PUSH/POP Stack for variable-length plate input
- Stores plates in buffer array using $ as delimiter
- Supports plate display and vehicle search

### Feature 4 — Time-Based Fee Calculation + Price Tier
- Uses INT 1AH to capture system ticks at entry and exit
- Regular: 20 Taka/hour, Premium: 40 Taka/hour, VIP: 80 Taka/hour
- Minimum 1-hour charge applied
- Prints formatted receipt on check-out

---

## 👥 Group Members

| Member | Features |
|---|---|
| Member 1 | Feature 1 and Feature 2 |
| Member 2 | Feature 3 and Feature 4 |

---

## 🚀 How to Run

1. Open EMU 8086
2. File → Open → car_parking_system_final.asm
3. Press F5 to Assemble
4. Press F9 to Run

---

*Made with ❤️ for CSE341 (Microprocessor Course) — BRAC University*
