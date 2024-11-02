
(in-package #:iv-debugger)

(cffi:defcfun ("wifexited" wifexited) :int
  (status :int))

(cffi:defcfun ("wexitstatus" wexitstatus) :int
  (status :int))

(cffi:defcfun ("wifsignaled" wifsignaled) :int
  (status :int))

(cffi:defcfun ("wtermsig" wtermsig) :int
  (status :int))

(cffi:defcfun ("wcoredump" wcoredump) :int
  (status :int))

(cffi:defcfun ("wifstopped" wifstopped) :int
  (status :int))

(cffi:defcfun ("wstopsig" wstopsig) :int
  (status :int))

(cffi:defcfun ("wifcontinued" wifcontinued) :int
  (status :int))

(defconstant +sighup+ 1)
(defconstant +sigint+ 2)
(defconstant +sigquit+ 3)
(defconstant +sigill+ 4)
(defconstant +sigtrap+ 5)
(defconstant +sigabrt+ 6)
(defconstant +sigbus+ 7)
(defconstant +sigfpe+ 8)
(defconstant +sigkill+ 9)
(defconstant +sigusr1+ 10)
(defconstant +sigsegv+ 11)
(defconstant +sigusr2+ 12)
(defconstant +sigpipe+ 13)
(defconstant +sigalrm+ 14)
(defconstant +sigterm+ 15)
(defconstant +sigstkflt+ 16)
(defconstant +sigchld+ 17)
(defconstant +sigcont+ 18)
(defconstant +sigstop+ 19)
(defconstant +sigtstp+ 20)
(defconstant +sigttin+ 21)
(defconstant +sigttou+ 22)
(defconstant +sigurg+ 23)
(defconstant +sigxcpu+ 24)
(defconstant +sigxfsz+ 25)
(defconstant +sigvtalrm+ 26)
(defconstant +sigprof+ 27)
(defconstant +sigwinch+ 28)
(defconstant +sigio+ 29)
(defconstant +sigpoll+ +sigio+)
