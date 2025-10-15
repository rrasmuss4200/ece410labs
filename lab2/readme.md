Color State:
Idle -> Red
Load -> Green
Countdown -> Blue
Done -> Cyan

Design Decisions:
- Reset will stop the execution and set the countdown back to 10, regardless of the prior value
- In the idle state it shows the previous loaded value which is the value that is loaded and what we will count down from
- After loading, then pressing load we get sent back to the idle state
- We have a DONE state however it is not fully needed.


Issues and things to discuss:
- The simulation result is different from the actual hardware implementation
    -> Loading works in hardware however it does not load in our simulation
- Some Issues:
    -> had a clock in our sensitivity list and used it in purly combinational block
    -> Had multiple clocks in our fsm
