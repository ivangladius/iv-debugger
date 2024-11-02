
(in-package #:iv-debugger)

(defconstant +ptrace-traceme+    0)
(defconstant +ptrace-peektext+   1)
(defconstant +ptrace-peekdata+   2)
(defconstant +ptrace-peekuser+   3)
(defconstant +ptrace-poketext+   4)
(defconstant +ptrace-pokedata+   5)
(defconstant +ptrace-pokeuser+   6)
(defconstant +ptrace-cont+       7)
(defconstant +ptrace-kill+       8)
(defconstant +ptrace-singlestep+ 9)
(defconstant +ptrace-getregs+    12)
(defconstant +ptrace-setregs+    13)
(defconstant +ptrace-getfpregs+  14)
(defconstant +ptrace-setfpregs+  15)
(defconstant +ptrace-attach+     16)
(defconstant +ptrace-detach+     17)
(defconstant +ptrace-syscall+    24)
(defconstant +wnohang+ 1)

(defconstant +esrch+ 3)
(defconstant +eperm+ 1)
(defconstant +eio+ 5)
(defconstant +einval+ 22)

(cffi:defctype pid-t :int)
(cffi:defctype size-t :unsigned-long)
(cffi:defctype ssize-t :long)


(cffi:defcfun ("ptrace" sys-ptrace) :long
  (request :int) (pid pid-t) (addr :pointer) (data :pointer))

(cffi:defcfun ("fork" sys-fork) pid-t)

(cffi:defcfun ("perror" sys-perror) :void
  (s :string))

(cffi:defcfun ("exit" sys-exit) :void
  (exit-code :int))

(cffi:defcfun ("pipe" sys-pipe) :int
  (pipefd :pointer))

(cffi:defcfun ("dup2" sys-dup2) :int
  (oldfd :int) (newfd :int))

(cffi:defcfun ("close" sys-close) :int
  (fd :int))

(cffi:defcfun ("read" sys-read) ssize-t
  (fd :int) (buf :pointer) (count size-t))

(cffi:defcfun ("execv" sys-execv) :int
  (pathname :string) (argv :pointer))

(cffi:defcfun ("waitpid" sys-waitpid) pid-t
  (pid pid-t) (status :pointer) (option :int))

(cffi:defcfun ("getpid" sys-getpid) pid-t)

(cffi:defcfun ("getppid" sys-getppid) pid-t)

(cffi:defcfun ("getpagesize" sys-getpagesize) :int)
