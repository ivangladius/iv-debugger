
(in-package #:iv-debugger)

(defconstant +ptrace-traceme+ 0)
(defconstant +wnohang+ 1)

(cffi:defctype pid-t :int)
(cffi:defctype size-t :unsigned-long)
(cffi:defctype ssize-t :long)


(cffi:defcfun ("ptrace" sys-ptrace) :long
  (request :int) (pid pid-t) (addr :pointer) (data :pointer))

(cffi:defcfun ("fork" sys-fork) pid-t)

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


