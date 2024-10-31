

(in-package #:iv-debugger)

(defstruct process-info
  name
  args
  child
  parent
  parent-parent
  uid
  gid
  stack-size
  signal-sent
  running)

