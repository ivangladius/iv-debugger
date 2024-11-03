# iv-debugger
Hackable debugger to hack the planet.



# TODO
* show dissassembly lines with the help of capstone
* implement elf parsing to get relative address of symbols to set breakpoints

# Optimizations
* store in \*previous-registers\* and \*next-registers\* only the 
  changed registers to save a huge amount of space, but which could
  slow down the time travel, or we only activate timetravel at certain 
  points or we write them down to list and only load the next 20 and previous 20
  ( maybe be the best solution )
  

  
