 🧠 Computer Architecture Project – Politecnico di Torino
 
 Repository for Computer Architecture assignments and experiments by three students of Politecnico di Torino.
 The goal is to collect, organize, and test RISC-V Assembly exercises using gem5 and custom scripts for compilation and execution.

---

# 👥 Authors
 
 | Name | Student ID | Role |
 |------|-------------|------|
 | *Student 1* | *sXXXXXX* | Assembly developer |
 | *Student 2* | *sXXXXXX* | gem5 and testing |
 | *Student 3* | *sXXXXXX* | Documentation and review |

---

# 🧩 Project Overview
 
 This repository contains:
 - RISC-V Assembly programs (.s files)
 - Helper scripts for compilation and simulation with gem5
 - Logs and output files for test verification
 
 Each assignment will typically include:

 program_test.s       → RISC-V assembly source file
 riscv_compile        → script to compile the assembly program
 gem5_run             → script to run the compiled binary in gem5
 gem5_config.py       → configuration file for gem5 simulation
 program_test.log     → execution log file (output)

---

# ⚙️ Repository Structure

 /project_root
 ├── README.md
 ├── riscv_compile
 ├── gem5_run
 ├── gem5_config.py
 ├── program_test.s
 └── program_test.log   (generated after running)

 ⚠️ Important:
 All files (scripts and .s sources) must be in the same folder when compiling and executing.

---

 🧠 Using Git & GitHub
 
 Here are the most important commands for collaboration and version control.

## 🔸 1. Clone the repository
 
 git clone https://github.com/your-username/ca-project.git
 cd ca-project

## 🔸 2. Create a new branch for your work
 
 git checkout -b your-feature-name

## 🔸 3. Add and commit your changes
 
 git add program_test.s
 git commit -m "Added new assembly test for flag computation"

## 🔸 4. Push your branch to GitHub
 
 git push origin your-feature-name

## 🔸 5. Merge changes via Pull Request (on GitHub)
 
 Open a Pull Request from your branch into main and request review from your teammates.

## 🔸 6. Update your local repository
 
 git pull origin main

---

# ⚙️ Compiling & Running Assembly Programs
 
 Once your .s file and scripts are in the same directory, use the following commands.

## 🔹 1. Compile the assembly file
 
 riscv_compile program_test.s

 This script compiles the RISC-V Assembly source into an executable binary compatible with gem5.

## 🔹 2. Run the simulation with gem5
 
 gem5_run gem5_config.py program_test program_test.log

 This command launches gem5 with the provided configuration file (gem5_config.py),
 executes your compiled program (program_test),
 and saves the output and statistics into the log file (program_test.log).

---

# 🧾 Tips
 
 - Always commit frequently and write clear commit messages.
 - Use branches for each new task or experiment.
 - Check .log files to verify correctness and performance.
 - When modifying scripts, document changes in this README or in separate notes.

---

# 🧩 Example Workflow
 
 # Clone repo and move into it
 git clone https://github.com/your-username/ca-project.git
 cd ca-project

 # Create your own branch
 git checkout -b feature-flag-check

 # Edit your assembly file
 nano program_test.s

 # Compile and run your program
 riscv_compile program_test.s
 gem5_run gem5_config.py program_test program_test.log

 # Commit and push results
 git add .
 git commit -m "Implemented strictly increasing/decreasing flag check"
 git push origin feature-flag-check

---

# 🧱 Recommended Workflow for Teams
 
 1. Each student works on a separate branch for their task.
 2. Before starting new work, pull the latest version from main.
 3. Test your code locally with riscv_compile and gem5_run.
 4. Create a Pull Request when your code is ready.
 5. Use reviews and comments on GitHub for code discussions.

---

# 🧰 Common Git Commands Reference
 
 | Command | Description |
 |----------|-------------|
 | git status | Shows modified and untracked files |
 | git log --oneline | Displays commit history |
 | git diff | Shows changes before committing |
 | git branch | Lists branches |
 | git merge branch_name | Merges another branch into the current one |
 | git remote -v | Lists repository remotes |
 | git reset --hard HEAD | Discards local changes (⚠️ use with care) |

---

 🧩 Useful Notes
 
 - Scripts like riscv_compile and gem5_run may require executable permissions.
   chmod +x riscv_compile gem5_run

 - Keep filenames simple and lowercase (no spaces or special characters).
 - Always verify that the .s file compiles before submitting assignments.
 - Include comments in your Assembly files explaining each register and instruction purpose.

---

# 🏁 License
 
 This repository is for educational purposes only within the Computer Architecture course at Politecnico di Torino.
 Use and modify freely for learning and experimentation.

---
